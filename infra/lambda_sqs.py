import base64
import boto3
import json
import random
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

MODEL_ID = "amazon.titan-image-generator-v1"
BUCKET_NAME = os.environ.get("BUCKET_NAME", "default-bucket-name")

def lambda_handler(event, context):
    logger.info("Lambda triggered with event: %s", json.dumps(event))

    for record in event.get("Records", []):
        try:
            prompt = record["body"]
            seed = random.randint(0, 2147483647)
            s3_image_path = f"images/titan_{seed}.png"
            logger.info(f"Processing prompt: {prompt} with seed {seed}")

            native_request = {
                "taskType": "TEXT_IMAGE",
                "textToImageParams": {"text": prompt},
                "imageGenerationConfig": {
                    "numberOfImages": 1,
                    "quality": "standard",
                    "cfgScale": 8.0,
                    "height": 512,
                    "width": 512,
                    "seed": seed,
                },
            }

            response = bedrock_client.invoke_model(
                modelId=MODEL_ID,
                body=json.dumps(native_request)
            )

            model_response = json.loads(response["body"].read())
            base64_image_data = model_response["images"][0]
            image_data = base64.b64decode(base64_image_data)
            logger.info(f"Image generated successfully for prompt: {prompt}")

            s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
            logger.info(f"Image uploaded to S3 at {s3_image_path}")

        except Exception as e:
            logger.error(f"Error processing record: {record}. Error: {str(e)}")

    logger.info(f"Function executed successfully for request: {context.aws_request_id}")
    return {
        "statusCode": 200,
        "body": json.dumps("Function executed successfully.")
    }
