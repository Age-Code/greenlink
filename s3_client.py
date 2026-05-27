from pathlib import Path
import os
import mimetypes

import boto3
from dotenv import load_dotenv


load_dotenv()


AWS_REGION = os.getenv("AWS_REGION", "ap-northeast-2")
S3_BUCKET = os.getenv("S3_BUCKET")

s3 = boto3.client(
    "s3",
    region_name=AWS_REGION,
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
)


def upload_file_to_s3(local_path: Path, s3_key: str) -> str:
    if not local_path.exists():
        raise FileNotFoundError(f"파일을 찾을 수 없습니다: {local_path}")

    if not S3_BUCKET:
        raise RuntimeError("S3_BUCKET 환경변수가 없습니다. .env를 확인하세요.")

    content_type, _ = mimetypes.guess_type(str(local_path))

    if content_type is None:
        content_type = "application/octet-stream"

    s3.upload_file(
        Filename=str(local_path),
        Bucket=S3_BUCKET,
        Key=s3_key,
        ExtraArgs={
            "ContentType": content_type,
        },
    )

    url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{s3_key}"
    return url
