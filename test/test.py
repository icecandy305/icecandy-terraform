import boto3
import json
import time
import datetime
from botocore.signers import CloudFrontSigner
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.backends import default_backend

ssm = boto3.client('ssm')
response = ssm.get_parameter(Name='XXXXXXXXXXX', WithDecryption=True)
private_key_pem = response['Parameter']['Value'].encode('utf-8')

private_key = serialization.load_pem_private_key(
    private_key_pem,
    password=None,
    backend=default_backend()
)

def rsa_signer(message):
    return private_key.sign(message, padding.PKCS1v15(), hashes.SHA1())

signer = CloudFrontSigner('XXXXXXX', rsa_signer)

policy = {
    "Statement": [{
        "Resource": "https://XXXXXX.cloudfront.net/customerA/*",
        "Condition": {
            "DateLessThan": {"AWS:EpochTime": int(time.time()) + 3600}
        }
    }]
}

signed_url = signer.generate_presigned_url(
    url="https://XXXXXXX.cloudfront.net/customerA/file.txt",
    policy=json.dumps(policy)
)

print(signed_url)
