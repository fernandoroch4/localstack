import os
import boto3

dyn = boto3.resource("dynamodb", region_name="us-east-1")
table = dyn.Table(os.environ["CATALOG_TABLE"])


def format_item_from_s3_record(record: dict) -> dict:
    """
    Format an item from an S3 record.
    """
    item = {
        "bucket": record["s3"]["bucket"]["name"],
        "key": record["s3"]["object"]["key"],
        "size": record["s3"]["object"]["size"],
        "eTag": record["s3"]["object"]["eTag"],
        "sequencer": record["s3"]["object"]["sequencer"],
    }
    return item


def put_item(item: dict, tb=table) -> None:
    """
    Put an item in the DynamoDB table.
    """
    tb.put_item(Item=item)


def main(event, context):
    assert "Records" in event, "No records found in event"

    for record in event["Records"]:
        try:
            item = format_item_from_s3_record(record)
            put_item(item)
        except Exception as e:
            print(e)
            return {"statusCode": 500, "body": str(e)}
        else:
            print(item)
            return {"statusCode": 200, "body": str(item)}
