variable "region" {
  description = "Name of the AWS region to deploy into"
  type        = string
}

variable "assume_role_arn" {
  type        = string
  description = "The AWS role to assume for the deployment"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Name of the app environment"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
}

variable "namespace" {
  type        = string
  description = "The kubernetes namespace to use"
}

variable "code_dir" {
  type        = string
  description = "The directory containing the application code"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = ""
}

variable "container_image_repo" {
  type        = string
  description = "repo containing the image"
  default     = "canopy-pipeline"
}

variable "container_image_tag" {
  type        = string
  description = "tag pointing to the right image"
  default     = "development"
}

variable "secret_name" {
  type        = string
  description = "the kubernetes secret containing the config"
  default     = "canopy-pipeline"
}

variable "app_config" {
  type        = map(string)
  description = "Additional configuration to pass to the app"
  default     = {}
}

variable "dagster_grpc_port" {
  type        = number
  description = "The port to use for the dagster grpc server"
  default     = 4266
}
