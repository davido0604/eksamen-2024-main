variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 bucket for storing files"
  default     = "pgr301-couch-explorers"
}

variable "suffix" {
  description = "Suffix for resource names to distinguish deployments"
  default     = "Kandidat57"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  default     = "dadi002@student.kristiania.no"
}
