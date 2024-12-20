import os
import json
import random
import boto3
import base64

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

def generate_image(prompt, bucket_name):
    try:
        seed = random.randint(0, 2147483647)
        s3_image_path = f"generated_images/titan_{seed}.png"

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
            },
        }

        response = bedrock_client.invoke_model(
            modelId="amazon.titan-image-generator-v1",
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())

        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

        s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)

        return f"https://{bucket_name}.s3.amazonaws.com/{s3_image_path}"
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    bucket_name = os.environ.get("BUCKET_NAME", "default-bucket-name")

    prompt = input("Enter a prompt for the image: ")

    image_url = generate_image(prompt, bucket_name)
    if image_url:
        print(f"Image successfully generated and uploaded to S3. URL: {image_url}")
    else:
        print("Failed to generate the image.")
