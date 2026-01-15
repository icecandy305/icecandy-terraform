resource "tls_private_key" "cloudfront_signer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_cloudfront_public_key" "customer_key" {
  name        = "customer-signing-key-${random_id.suffix.hex}"
  encoded_key = tls_private_key.cloudfront_signer.public_key_pem
  comment     = "Auto-generated signing key"
}

# 3. Key Group（公式仕様）
resource "aws_cloudfront_key_group" "customer_key_group" {
  name    = "customer-key-group-${random_id.suffix.hex}"
  comment = "Customer files signing"
  items   = [aws_cloudfront_public_key.customer_key.id] 
}

resource "random_id" "suffix" {
  byte_length = 4
}

# 4. SSMに秘密鍵安全保管
resource "aws_ssm_parameter" "cloudfront_private_key" {
  name  = "/cloudfront/customer-private-key"
  type  = "SecureString"
  value = tls_private_key.cloudfront_signer.private_key_pem
}

