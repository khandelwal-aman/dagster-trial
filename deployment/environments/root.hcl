iam_role = "arn:aws:iam::221120163160:role/terraform-user"

remote_state {
  backend = "s3"
  config = {
    bucket = "canopy-awsconfig"
    key = "terraform/applications/canopy-pipeline/canopy-pipeline-template/${path_relative_to_include()}.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
    skip_region_validation = true
  }
}
