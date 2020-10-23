# jetson_demos

Steps to run Jetson_demos

1. Activate Docker container
```sh
$ sudo docker run --runtime nvidia -it --name demo --network host     --volume ~/nvdli-data:/nvdli-nano/data     nvcr.io/nvidia/dli/dli-nano-ai:v2.0.0-r32.4.3
```
2. Clone this repository
```sh
$ git clone https://github.com/HtutLynn/jetson_demos.git
$ cd jetson_demos
```

3. install system dependencies to install required python packages
```sh
./install_system_dependencies.sh
```

4. Download YOLO weight files, install python dependencies and convert to TensorRT runtime models
```sh
cd yolo
./download_convert.sh
```

5. Run the monitoring pipeline
```sh
python3 main.py --upload False
```