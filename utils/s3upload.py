import boto3
import base64
from botocore.exceptions import NoCredentialsError

class VideoUploader(object):
    """
    Uploader function for uploading video file to S3 Bucket
    """
    def __init__(self, profile_name="default", bucketName=None):
        """
        Initialize parameters, required for uploading files to AWS S3 bucket.

        Parameters
        ----------
        access_key  : str
                      access_key to Amazon S3 Bucket instance
        secret_key  : str
                      secret key to Amazon S3 Bucket instance
        bucket      : str
                      Amazon S3 bucket
        """
        if bucketName is None:
            self.bucketName = "altotechpublic"

        session = boto3.Session(profile_name=profile_name)
        # self.s3 = boto3.client('s3', aws_access_key_id=self.access_key,
        #                         aws_secret_access_key=self.secret_key)
        self.s3_resource = session.resource('s3')
        
    def upload(self, local_file, s3_file):
        """
        Upload video file to S3 bucket.

        Parameters
        ----------
        local_file  : str
                      Local path to the file, to be uploaded
        s3_file     : str
                      Filename in s3 bucket
        """
        s3_file = "naplabchula/Photos/jetson/" + s3_file
        print("Uploading the file...")
        try:
            # self.s3_resource.upload_file(local_file, self.bucket, s3_file)
            # self.s3_resource.Bucket(self.bucketName).upload_file(local_file, s3_file)
            binary_data = open(local_file, 'rb')
            self.s3_resource.Bucket(self.bucketName).put_object(Key=s3_file, Body=binary_data, ContentType='video/mp4')
            print("Upload Successful!")
            return True
        except FileNotFoundError:
            print("The file was not found.")
            return False
        except NoCredentialsError:
            print("Credentials not available.")
            return False
