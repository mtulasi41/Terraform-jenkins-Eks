variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default = "172.20.0.0/16"
}

variable "public_subnets" {
  description = "subnets CIDR"
  type        = list(string)
  default = [ "172.20.3.0/24", "172.20.4.0/24" ]
}

variable "private_subnets" {
  description = "subnets CIDR"
  type        = list(string)
  default = [ "172.20.5.0/24", "172.20.6.0/24" ]
}