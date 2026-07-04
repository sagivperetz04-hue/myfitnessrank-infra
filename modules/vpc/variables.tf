variable "name" {
  description = "Name prefix for the VPC and its resources"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across (EKS requires at least two)"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets (worker nodes), one per AZ"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets (load balancers), one per AZ"
  type        = list(string)
}
