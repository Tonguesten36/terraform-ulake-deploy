variable "subscription_id" {
  type    = string
  default = "069b9d39-a5a8-4511-a1d4-2fbd650452ca"
}

variable "rg_name" {
  type    = string
  default = "ulake-rg"
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "container_env_name" {
  type    = string
  default = "ulake-network"
}

variable "mysql_server_name" {
  type    = string
  default = "ulake-mysql"
}

variable "mysql_admin_name" {
  type    = string
  default = "ulake_admin"
}

variable "mysql_admin_password" {
  type        = string
  default     = "SecurePass123!"
  description = "The password used for logging in to the primary admin account"
}


