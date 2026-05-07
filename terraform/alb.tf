# ALB用のセキュリティグループ
resource "aws_security_group" "alb" {
    name = "${var.project_name}-alb-sg"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Project = var.project_name
    }
}

# ALB本体
resource "aws_lb" "main" {
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = data.aws_subnets.default.ids

    tags = {
        Project = var.project_name
    }
}

# ターゲットグループ
resource "aws_lb_target_group" "app" {
    name = "${var.project_name}-tg"
    port = 8000
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    target_type = "ip"

    #ヘルスチェック:定期的にこのパスにリクエストして200～302が返れば正常判定
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
