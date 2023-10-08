variable "custom_domain" {
  description = "Your custom domain"
  type        = string
  default     = "4bleacherreport.com"
}

variable "custom_domain_zone_name" {
  description = "The Route53 zone name of the custom domain"
  type        = string
  default     = "4bleacherreport.com"
}

variable "lambda_dir" {
  description = "The directory where the lamdba's are stored"
  type        = string
  default     = "../../.open-next"
}

variable "cloudfront_cert" {
  type = string
  default = "arn:aws:acm:us-east-1:867690557112:certificate/c218680d-980e-4bfd-b239-d4512bfc23c4"
}

variable "env" {
  description = "Deployment environment"
  type = string
  default = "dev"
}

variable "service_name" {
  description = "Service Name"
  type = string
  default = "br-nodereport"
}
