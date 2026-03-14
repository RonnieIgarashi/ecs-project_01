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
            port_mappings = [
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

