locals {
  image_repo          = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  container_image_tag = "${local.project_name}-${var.container_image_tag}"
  full_image_repo     = "${local.image_repo}/${var.container_image_repo}"
  full_image_prefix   = "${local.full_image_repo}:${local.container_image_tag}"
}

resource "null_resource" "docker_image" {
  triggers = {
    timestamp         = timestamp()
    code_dir          = var.code_dir
    full_image_prefix = local.full_image_prefix
  }

  provisioner "local-exec" {
    command     = "scripts/build-docker.sh"
    interpreter = ["bash"]
    working_dir = self.triggers.code_dir
    environment = {
      IMAGE_TAG_PREFIX = self.triggers.full_image_prefix
    }
  }
}

data "aws_ecr_authorization_token" "auth" {}

resource "null_resource" "remote_docker_authorization" {
  triggers = {
    timestamp    = timestamp()
    image_repo   = local.image_repo
    ecr_password = sha1(data.aws_ecr_authorization_token.auth.password)
    ecr_username = data.aws_ecr_authorization_token.auth.user_name
  }

  provisioner "local-exec" {
    command     = "echo $AWS_ECR_PASSWORD | docker login --username $AWS_ECR_USERNAME --password-stdin ${self.triggers.image_repo} || true"
    interpreter = ["bash", "-c"]
    environment = {
      AWS_ECR_PASSWORD = data.aws_ecr_authorization_token.auth.password
      AWS_ECR_USERNAME = self.triggers.ecr_username
    }
  }
  depends_on = [null_resource.docker_image]
}

resource "null_resource" "remote_docker_image" {
  triggers = {
    timestamp         = timestamp()
    full_image_prefix = local.full_image_prefix
  }

  provisioner "local-exec" {
    command     = "docker push ${self.triggers.full_image_prefix}"
    interpreter = ["bash", "-c"]
  }
  depends_on = [null_resource.docker_image, null_resource.remote_docker_authorization]
}
