import json
import os
import boto3
import base64
import random

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

bucket_name = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    """Lambda function for generating images with AWS Bedrock and saving to S3."""
    try:
        body = json.loads(event.get("body", "{}"))
        prompt = body.get("prompt")
        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'prompt' in request body"})
            }

        candidate_number = "57"
        seed = random.randint(0, 2147483647)
        s3_image_path = f"{candidate_number}/generated_images/titan_{seed}.png"

        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }

        response = bedrock_client.invoke_model(
            modelId="amazon.titan-image-generator-v1",
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())
        
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

        s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)

        image_url = f"https://{bucket_name}.s3.amazonaws.com/{s3_image_path}"

        return {
            "statusCode": 200,
            "body": json.dumps({"image_url": image_url})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
