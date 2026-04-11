data "aws_vpc" "default" {
    id = var.vpc_id
}

data "aws_subnets" "default" {
    filter {
        name   = "subnet-id"
        values = var.subnet_ids
    }
}
