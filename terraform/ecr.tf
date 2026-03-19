resource "aws_ecr_repository" "app" {
    name = var.project_name

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Project = var.project_name
    }
}