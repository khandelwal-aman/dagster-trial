terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [
      "true"
    ] : []
    content {
      role_arn = var.assume_role_arn
    }
  }
  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "self" {}

data "external" "project_name" {
  program     = ["${var.code_dir}/scripts/get-project-name.sh", "json"]
  working_dir = var.code_dir
}


locals {
  project_name     = var.project_name != "" ? var.project_name : data.external.project_name.result["name"]
  full_name_prefix = "${var.environment}-${local.project_name}"

  account_id = data.aws_caller_identity.self.account_id
  stack      = "canopy-pipeline/${local.project_name}/${var.environment}"

  tags = {
    "aws.kurtosys.org/stack"             = local.stack
    "aws.kurtosys.org/app"               = "canopy-pipeline/${local.project_name}"
    "aws.kurtosys.org/app-environment"   = var.environment
    "aws.kurtosys.org/terraform-managed" = "true"
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

locals {
  kubernetes_auth = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  host                   = local.kubernetes_auth.host
  cluster_ca_certificate = local.kubernetes_auth.cluster_ca_certificate
  token                  = local.kubernetes_auth.token

  //noinspection HCLUnknownBlockType
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    host                   = local.kubernetes_auth.host
    cluster_ca_certificate = local.kubernetes_auth.cluster_ca_certificate
    token                  = local.kubernetes_auth.token
  }
}

data "aws_kms_alias" "s3_key" {
  name = "alias/environment/${var.vpc_name}/s3"
}
