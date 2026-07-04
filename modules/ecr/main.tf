module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.2"

  for_each = toset(var.repository_names)

  repository_name = each.value

  repository_image_tag_mutability = "MUTABLE"
  repository_image_scan_on_push   = true
  repository_force_delete         = true

  create_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last ${var.keep_last_images} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.keep_last_images
      }
      action = { type = "expire" }
    }]
  })
}
