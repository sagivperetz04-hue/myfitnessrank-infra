variable "repository_names" {
  description = "ECR repository names to create (one per service)"
  type        = list(string)
}

variable "keep_last_images" {
  description = "How many images each repository retains before the lifecycle policy expires old ones"
  type        = number
  default     = 10
}
