#define prefix for this api specific resources and other components
variable "prefix" {
  default = "rmmaa-"
}


variable "project" {
  default = "restaurant-menu-management-app-api"
}

variable "contact" {
  default = "nityanandakuamrsharma@gmail.com"
}

variable "db_username" {
  description = "USERNAME for the RDS Postgres instance"
}

variable "db_password" {
  description = "PASSOWRD for the RDS postgres instance"
}

#ssh key for bastion, the one which you already created via console using ssh-key gen. 
variable "bastion_key_name" {
  default = "res-menu-mgmt-app-api-bastion-keypair"
}


##################

variable "ecr_image_api" {
  description = "ECR Image for API"
  default     = "<acoount_is>.dkr.ecr.us-east-1.amazonaws.com/res-menu-mgmt-app-api:latest"
}

variable "ecr_image_proxy" {
  description = "ECR Image for API"

  #this default will be overrriden by .gitlab-ci.yml's $ECR_REPO:$CI_COMMIT_SHA
  default = "<acoount_is>.dkr.ecr.us-east-1.amazonaws.com/res-menu-mgmt-app-api-proxy:latest"
}

#django secret key
variable "django_secret_key" {
  description = "Secret key for Django app"
}
