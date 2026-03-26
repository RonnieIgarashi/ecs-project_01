resource "aws_ecs_cluster" "main" {
    name = "${var.project_name}-cluster"

    tags = {
        Project = var.project_name
    }
}

resource "aws_ecs_task_definition" "app" {
    family = "${var.project_name}-task"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]

    cpu = "256"
    memory = "512"

    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([
        {
            name = "flask"
            image = "${aws_ecr_repository.app.repository_url}:latest"
            portMappings = [
                {
                    container_port = 5000
                    protocol = "tcp"
                }
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = aws_cloudwatch_log_group.ecs.name
                    awslogs-region = var.aws_region
                    awslogs-stream-prefix = "ecs"
                }
            }
        }
    ])
}

resource "aws_security_group" "ecs_service" {
    name = "${var.project_name}-sg"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# フェーズ2（docker push後）に解除
# resource "aws_ecs_service" "app" {
#     name = "${var.project_name}-service"
#     cluster = aws_ecs_cluster.main.id
#     task_definition = aws_ecs_task_definition.app.arn
#
#     launch_type = "FARGATE"
#     desired_count = 1
#
#     network_configuration {
#         subnets = data.aws_subnets.default.ids
#         security_groups = [aws_security_group.ecs_service.id]
#         assign_public_ip = true
#     }
# }