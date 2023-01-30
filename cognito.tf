locals {
  callback_urls = concat(["https://${var.domain}${var.cognito_path_parse_auth}"], formatlist("%s${var.cognito_path_parse_auth}", var.cognito_additional_redirects))
  logout_urls   = concat(["https://${var.domain}${var.cognito_path_logout}"], formatlist("%s${var.cognito_path_logout}", var.cognito_additional_redirects))
}


module "cognito-user-pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.20.1"

  user_pool_name         = "${var.name}-userpool"
  domain                 = "${var.cognito_domain_prefix}.${aws_route53_record.website-domain.name}"
  domain_certificate_arn = module.acm.acm_certificate_arn

  clients = [
    {
      name                         = "${var.name}-client"
      supported_identity_providers = ["COGNITO"]

      generate_secret                      = true
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_scopes                 = ["openid"]
      callback_urls                        = local.callback_urls
      logout_urls                          = local.logout_urls
    },
  ]
}

