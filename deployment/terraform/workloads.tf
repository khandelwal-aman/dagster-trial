locals {
  default_code_servers = {
    "canopy-pipeline" = "pipeline"
  }
}

module "workloads" {
  source       = "git::https://github.com/Mesitis/canopy-terraform-modules//eks/workloads"
  cluster_name = var.cluster_name
  charts       = [
    {
      enabled    = true
      name       = local.project_name
      namespace  = var.namespace
      chart      = "dagster-user-deployments"
      repository = "https://dagster-io.github.io/helm"
      version    = "1.3.5"
      values     = jsonencode({
        version     = 1
        fullnameOverride = "code-server-${var.project_name}"
        global = {
          fullnameOverride = "code-server-${var.project_name}"
          serviceAccountName = var.project_name
        }
        serviceAccount = {
          create = false
          name = var.project_name
        }
        deployments = [
          {
            name  = local.project_name
            image = {
              repository = local.full_image_repo
              tag        = local.container_image_tag
              pullPolicy = "Always"
            }
            dagsterApiGrpcArgs = [
              "--inject-env-vars-from-instance",
              "-d",
              "/app",
              "--module-name",
              "pipeline",
              "--host",
              "0.0.0.0",
              "--port",
              tostring(var.dagster_grpc_port)
            ]
            includeConfigInLaunchedRuns = {
              enabled = true
            }
            port       = var.dagster_grpc_port
            envSecrets = [
              {
                name     = var.secret_name
                optional = true
              }
            ]
            env = concat(
              [
                {
                  name  = "ENVIRONMENT"
                  value = var.environment
                },
                {
                  name  = "IMAGE_UPDATED_AT"
                  value = timestamp()
                }
              ],
              [
                for k, v in var.app_config : {
                name  = k
                value = v
              }
              ]
            )
          }
        ]
      })
    }
  ]
  depends_on = [
    module.service_accounts,
    null_resource.remote_docker_image
  ]
  overrides = jsonencode({})
}
