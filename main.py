# import tensorrt related libraries
from os import write
import pycuda.driver as cuda
import tensorrt as trt

# import system libraries
import os
import cv2
import time
import argparse
import threading
import numpy as np

# import helper functions
from utils.yamlparser import YamlParser
from utils.transform import Transform

# import tensorrt runtime wrapper 
from yolov4 import TrtYOLOv4

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--video", type=str, default="data/example.mp4")
    parser.add_argument("--model", type=str, default="yolo/yolov4-288.trt")
    parser.add_argument("--conf_threshold", type=float, default=0.3)
    parser.add_argument("--nms_threshold", type=float, default=0.5)
    parser.add_argument("--config", type=str, default="view.yaml")
    parser.add_argument("--record", type=bool, default=True)

    return parser.parse_args()

def visualize(image, preds, fps):
    """
    Vsiualize the inference results
    """
    # show inference info
    fps_text = "FPS : {:.2f}".format(fps)
    cv2.putText(image, fps_text, (11, 40), cv2.FONT_HERSHEY_PLAIN, 4.0, (32, 32, 32), 4, cv2.LINE_AA)

    if preds.shape[0] != 0:
        for box in preds:
            (x1, y1, x2, y2) = box.astype(np.int)
            cv2.rectangle(image, (x1, y1), (x2, y2), (255, 255, 0), 2)

    return image

class CascadeTrtThread(threading.Thread):
    """Cascade model TensorRT child thread

    This implements the child thread which continues to read images
    from cam(input) and to do Cascade TensorRT engine inferencing.
    The child thread stores and the input image and inferred results
    into global variables, and uses a condition varaiable to inform
    main thread. In other words, this thread acts as the producer 
    while thread is the consumer.
    """

    def __init__(self, condition, cfg, cam):
        """
        Setup parameters required YOLOv4 TensorRT engine

        Parameters
        ----------
        condition : Threading condition
                    The condition variable, used to notify main
                    thread about new frame and detection result,
        cam       : The camera object for reading input image frames

        cfg       : argument parser
                    Dictionary like object, containing all the required
                    informations

        Attributes
        ----------
        model           : str
                          Path of the Human Detection TensorRT engine file
        conf_threshold  : int
                          Threshold value for confidence
        nms_threshold   : int
                          Threshold value for non-maximum suppression
        """

        threading.Thread.__init__(self)
        self.condition           = condition
        self.model               = cfg.model
        self.conf_threshold      = cfg.conf_threshold
        self.nms_threshold       = cfg.nms_threshold

        assert os.path.isfile(self.model), "TensorRT runtime model doesn't exist!"

        # Threading attributes
        # NOTE: cuda_ctx code has been moved into Cascade model TensorRT class
        #self.cuda_ctx = None  # to be created when run

        self.cam = cam
        self.running = False

    def run(self):
        """Run until 'running' flag is set to False by main thread

        NOTE: CUDA context is created here, i.e. inside the thread
        which calls CUDA kernels.  In other words, creating CUDA
        context in __init__() doesn't work.
        """

        global image, preds, write_flag

        print("YOLOv4TrtThread: Loading the Engine...")

        # build the YOLOv4 TensorRT model engine
        self.yolov4_trt = TrtYOLOv4(engine_path=self.model, input_shape=(288, 288), nms_thres=self.nms_threshold, conf_thres=self.conf_threshold)

        
        print("YOLOv4TrtThread: start running...")
        self.running = True
        while self.running:
            ret, frame = self.cam.read()

            if ret:
                results = self.yolov4_trt.detect(frame)
                with self.condition:
                    preds      = results
                    image      = frame
                    write_flag = True
                    self.condition.notify()
            else:
                with self.condition:
                    write_flag = False
                    self.condition.notify()

        # delete the model after inference process
        del self.yolov4_trt

        print("YOLOv4TrtThread: stopped...")

    def stop(self):
        self.running = False
        self.join()


def compute_centroids(boxes):
    if len(boxes) == 0:
        return np.zeros((0, 2))
    else:
        centroids = np.zeros((len(boxes), 2))
        for i, box in enumerate(boxes):
            centroids[i][0] = float((box[0] + box[2]) *  0.5)
            centroids[i][1] = float((box[1] + box[3]) *  0.5)

        return centroids.astype(np.float32)

def get_scale(W, H):
    
    dis_w = 200
    dis_h = 600
    
    return float(dis_w/W),float(dis_h/H)

def concat_images(vis_img, be_img):
    """
    Concatenate two images

    Parameters
    ----------
    vis_img : numpy array image
              cv2 image in Height x Width x Channel format
    be_img  : numpy array image
              cv2 image in Height x Width x Channel format

    Returns
    -------
    conat_image : numpy array image
                  concatenated numpy array image
    """

    concat_height = vis_img.shape[0]
    be_height     = be_img.shape[0]

    be_canvas = np.zeros((concat_height, be_img.shape[1], 3))
    
    h = int((concat_height - be_height)/ 2)
    be_canvas[h:be_height+h, :, :] = be_img

    concat_image = np.hstack((vis_img, be_canvas))

    return concat_image.astype(np.uint8)

def monitor(condition, cfg, input_size):
    """
    1. Perform bird-eye view transformation based on results.
    2. Save the inferred results

    Parameters
    ----------
    condition : Threading condition
                Used to parse value from TensorRT thread
    cfg       : argument parser
                Dictionary like object, containing all the required
                informations
    """

    global image, preds, write_flag


    view = str(cfg.config)
    # check whether the files exists or not
    assert os.path.isfile(view), "Configuration file doesn't exist!"

    # parse data from arguments
    input_size = input_size

    # container for storing fps values
    all_fps = []

    T = Transform()

    # writer
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    path = "monitor_record.mp4"
    writer = cv2.VideoWriter(path, fourcc, 20, (1480, input_size[1]), True)

    # Setup parameters for generating bird-eye view
    # generate transform matrix
    # get polygon shaped ROI coordinates
    view_cfg = YamlParser(view)
    tl = view_cfg.top_left
    tr = view_cfg.top_right
    br = view_cfg.bot_right
    bl = view_cfg.bot_left
    scale_w, scale_h = get_scale(input_size[0], input_size[1])
    transform_matrix = T.compute_perspective_transform(corner_points=(tl, tr, br, bl),
                                                        width=input_size[0],
                                                        height=input_size[1])
    fps = 0.0
    tic = time.time()
    
    while True:
        with condition:
            # Wait for the next frame and detection result.  When
            # getting the signal from the child thread, save the
            # references to the frame and detection result for
            # deepsortcount tracker. And then display.
            condition.wait()
            frame, results, flag = image, preds, write_flag
            # Compute bird-eye view transformation
            centroids = compute_centroids(results)
            
            # Computer ground centroids by using Transform matrix
            new_centroids = T.compute_point_perspective_transform(transform_matrix=transform_matrix,
                                                                  centroids=centroids)

            # generate bird-eye image
            bird_eye_image = T.bird_eye_view_transform(frame, new_centroids, scale_w=scale_w, scale_h=scale_h)
            
            visualize_image = visualize(frame, results, fps)
            all_fps.append(int(fps))
            
            toc = time.time()
            curr_fps = 1.0 / (toc - tic)
            # calculate an exponentially decaying average of fps number
            fps = curr_fps if fps == 0.0 else (fps*0.95 + curr_fps*0.05)
            tic = toc

        # print(flag)            
        if flag:
            monitor_img = concat_images(visualize_image, bird_eye_image)
            writer.write(monitor_img)
        else:
            break

    all_fps = np.array(all_fps)
    print("Average FPS : {}".format(np.average(all_fps)))
    print("Lowest  FPS : {}".format(np.amin(all_fps)))
    print("Highest FPS : {}".format(np.amax(all_fps)))

def _set_window(video_path,  window_name, title):
    """Set the width and height of the video if self.record is True
    """

    assert os.path.isfile(video_path), "Path error"
    vc = cv2.VideoCapture()
    vc.open(video_path)
    im_width = int(vc.get(cv2.CAP_PROP_FRAME_WIDTH))
    im_height = int(vc.get(cv2.CAP_PROP_FRAME_HEIGHT))

    return (im_width, im_height)

def main():
    """
    Main function for running bird-eye view monitoring.

    Attributes
    ----------
    video      : str
                      Path of the source demo video
    model      : str
                      path of the TensorRT runtime model
    conf_threshold : float
                     Threshold value for filtering low-confidence detections
    nms_threshold  : float
                     Threshold value for non-maximum suppresion
    """

    # initiate cuda

    cuda.init()

    # parse arguments
    args = parse_args()
    print(args)
    video = args.video
    assert os.path.isfile(video), "TensorRT runtime model doesn't exist!"

    # set cv2 window
    WINDOW_NAME = "Monitoring with Jetson"
    title = "TensorRT accelearted YOLOv4"
    input_size = _set_window(video, WINDOW_NAME, title)


    # open a videofile, using cv2
    cam = cv2.VideoCapture(video)

    # threading condition
    condition  = threading.Condition()
    trt_thread = CascadeTrtThread(condition, args, cam)
    trt_thread.start()
    monitor(condition, args, input_size)
    trt_thread.stop()

    cam.release()

if __name__ == "__main__":
    main()