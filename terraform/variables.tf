variable "project_name" {
    default = "ecs-project-01"
}

variable "aws_region" {
    default = "ap-northeast-1"
}

variable "vpc_id" {
    default = "vpc-5898bc3f"
}

variable "subnet_ids" {
    default = ["subnet-482fc763", "subnet-3d3edf75"]
}
