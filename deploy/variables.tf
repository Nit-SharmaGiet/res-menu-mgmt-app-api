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
