#!/usr/bin/env python3
import os
import boto3

R2_BUCKET_NAME = os.environ["R2_BUCKET_NAME"]
R2_TOKEN_VALUE = os.environ["R2_TOKEN_VALUE"]
R2_ACCESS_KEY_ID = os.environ["R2_ACCESS_KEY_ID"]
R2_SECRET_ACCESS_KEY = os.environ["R2_SECRET_ACCESS_KEY"]
R2_JURISDICTION_SPECIFIC_ENDPOINTS = os.environ["R2_JURISDICTION_SPECIFIC_ENDPOINTS"]

s3 = boto3.client("s3",
                  endpoint_url = R2_JURISDICTION_SPECIFIC_ENDPOINTS,
                  aws_access_key_id = R2_ACCESS_KEY_ID,
                  aws_secret_access_key = R2_SECRET_ACCESS_KEY)


with open("resume.pdf", "rb") as resume:
    s3.upload_fileobj(resume, R2_BUCKET_NAME, "resume.pdf")
