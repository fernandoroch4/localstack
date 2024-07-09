import random
from datetime import datetime
import boto3
import json


BUCKET_NAME = "temp"
s3 = boto3.resource("s3", region_name="us-east-1", endpoint_url="http://localhost:4566")
bucket = s3.Bucket(BUCKET_NAME)

queue_files = []
default_files = []


def generate_key() -> str:
    """Generate a random key for the S3 object.
    The key is in the format: {prefix}/{random_number}-{timestamp}.{extension}
    The prefix is either "default" or "queue"
    The random_number is a random integer between 0 and 99999999999
    The timestamp is the current date and time in ISO format
    The extension is a random extension from txt, pdf, csv, html, xlsx, or doc
    :return: The generated key
    """
    prefix = random.choice(["default", "queue"])
    random_number = round(random.random() * 99999999999)
    timestamp = datetime.now().isoformat()
    extension = random.choice(["txt", "pdf", "csv", "html", "xlsx", "doc"])
    key = f"{prefix}/{random_number}-{timestamp}.{extension}"
    if prefix == "queue":
        queue_files.append(key)
    else:
        default_files.append(key)
    return key


def generate_data(client=bucket) -> None:
    """Generate random data in the S3 bucket.
    :param client: The S3 client
    """
    for _ in range(random.randint(1, 10)):
        client.put_object(
            Body=str(random.random()).encode(),
            Key=generate_key(),
            ContentLength=random.randint(9999, 9999999999999),
        )


if __name__ == "__main__":
    generate_data()
    print(json.dumps({"queue": queue_files, "default": default_files}, indent=4))
