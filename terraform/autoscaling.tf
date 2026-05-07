# ============================================================
# ECS Auto Scaling
# ============================================================

resource "aws_appautoscaling_target" "ecs" {
    service_namespace = "ecs"
    resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
    scalable_dimension = "ecs:service:DesiredCount"
    min_capacity = 1
    max_capacity = 3
}

# TargettrackinScalingポリシー
resource "aws_appautoscaling_policy" "cpu_tracking" {
    name = "${var.project_name}-cpu-tracking"
    policy_type = "TragetTrackingScaling"
    service_namespace = "aws_appautoscaling_target.ecs.service_namespace"
    resource_id = "aws_appautoscaling_target.ecs.resource_id"
    scalable_dimension = "aws_appautoscaling_target.ecs.scalable_dimension"

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 60.0
        scale_out_cooldown = 60
        scale_in_cooldown = 300
    }
}

# ターゲットグループ
resource "aws_lb_target_group" "app" {
    name = "${var.project_name}-tg"
    port = 8000
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    target_type = "ip"

    health_check {
        path = "/admin/login/"
        matcher = "200"
        healthy_threshold = 2
        unhealthy_threshold = 3
        interval = 30
        timeout = 5
    }
    
    tags = {
        Project = var.project_name
    }
}

# リスナー
resource "aws_lb_listner" "http" {
    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app.arn
    }
}

