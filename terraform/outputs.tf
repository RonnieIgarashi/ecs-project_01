output "vpc_id" {
    value = data.aws_vpc.default.id
}

output "ecr_repository_url" {
    description = "ECR リポジトリ URL（docker tag / docker push で使用）"
    value       = aws_ecr_repository.app.repository_url
}

output "aurora_endpoint" {
    description = "Aurora クラスターエンドポイント（接続確認用）"
    value       = aws_rds_cluster.postgres.endpoint
}

output "alb_dns_name" {
    description = "ALB DNS 名"
    value = "http://${aws_lb.main.dns_name}"
}
