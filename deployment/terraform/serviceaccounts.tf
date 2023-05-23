module "service_accounts" {
  source         = "git::https://github.com/Mesitis/canopy-terraform-modules//eks/service_accounts"
  cluster_name   = var.cluster_name
  name           = var.vpc_name
  override_names = {
    (local.project_name) = "eks-${var.environment}-pipeline-${local.project_name}"
  }
  service_accounts = [
    {
      name                     = local.project_name
      namespace                = var.namespace
      attach_policy_arns       = []
      with_k8s_service_account = true
      rw_buckets               = []
      ro_buckets               = []
      inline_policies          = []
    }
  ]
  providers = {
    aws       = aws
    aws.roles = aws
  }
}
