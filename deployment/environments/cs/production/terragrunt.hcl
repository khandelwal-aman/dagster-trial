include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  code_dir         = dirname(dirname(get_parent_terragrunt_dir()))
  code_environment = basename(get_terragrunt_dir())
  environment      = "${basename(dirname(get_terragrunt_dir()))}-${local.code_environment}"
}

terraform {
  source = "../../../terraform///"
}

inputs = {
  code_dir               = local.code_dir
  environment            = local.environment
  container_image_tag    = local.code_environment
  region                 = "ap-southeast-1"
  vpc_name               = "se1-cs-production"
  cluster_name           = "se1-cs-production"
  namespace              = "production-pipeline"
  assume_role_arn        = "arn:aws:iam::351541594782:role/terraform-access"
  app_config             = {}
}
