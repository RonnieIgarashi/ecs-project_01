# ============================================================
# Aurora PostgreSQL クラスター（フェーズ2）
# 使用時以外は terraform destroy で削除すること
# ============================================================

# セキュリティグループ（Aurora 用）
resource "aws_security_group" "aurora" {
    name   = "${var.project_name}-aurora-sg"
    vpc_id = data.aws_vpc.default.id

    # ECS サービスの SG からのみ 5432 を許可
    ingress {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        security_groups = [aws_security_group.ecs_service.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Project = var.project_name
    }
}

# DB サブネットグループ（2 AZ 必須）
resource "aws_db_subnet_group" "aurora" {
    name       = "${var.project_name}-aurora-subnet-group"
    subnet_ids = data.aws_subnets.default.ids

    tags = {
        Project = var.project_name
    }
}

# Aurora PostgreSQL クラスター
resource "aws_rds_cluster" "postgres" {
    cluster_identifier      = "${var.project_name}-aurora"
    engine                  = "aurora-postgresql"
    engine_version          = "16.13"
    database_name           = "ecs_prj_library_db"
    master_username         = "postgres"
    master_password         = var.db_password
    db_subnet_group_name    = aws_db_subnet_group.aurora.name
    vpc_security_group_ids  = [aws_security_group.aurora.id]
    skip_final_snapshot     = true   # destroy 時にスナップショット不要
    deletion_protection     = false  # destroy を確実に通す

    tags = {
        Project = var.project_name
    }
}

# Aurora インスタンス（最小クラス）
resource "aws_rds_cluster_instance" "postgres" {
    identifier         = "${var.project_name}-aurora-instance"
    cluster_identifier = aws_rds_cluster.postgres.id
    instance_class     = "db.t3.medium"
    engine             = aws_rds_cluster.postgres.engine
    engine_version     = aws_rds_cluster.postgres.engine_version

    tags = {
        Project = var.project_name
    }
}
