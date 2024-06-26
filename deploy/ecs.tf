resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

#######################################
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow fetching images from ECR and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

#running time permission provider to tasks: basic
resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-api-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

#log group
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"

  tags = local.common_tags
}


########################################
data "template_file" "api_container_definitions" {
  template = file("./templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image                = var.ecr_image_api
    proxy_image              = var.ecr_image_proxy
    django_secret_key        = var.django_secret_key
    db_host                  = aws_db_instance.main.address
    db_name                  = aws_db_instance.main.db_name
    db_user                  = aws_db_instance.main.username
    db_pass                  = aws_db_instance.main.password
    log_group_name           = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region         = data.aws_region.current.name
    allowed_hosts            = aws_lb.api.dns_name
    s3_storage_bucket_name   = aws_s3_bucket.app_public_files.bucket
    s3_storage_bucket_region = data.aws_region.current.name
  }
}


#ECS Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.prefix}-api"
  container_definitions    = data.template_file.api_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = aws_iam_role.app_iam_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  volume {
    name = "static"
  }

  tags = local.common_tags
}




###add security group for ECS service
resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  #to public
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #to private subnetted db
  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }

  #from public to proxy
  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}


#create the servive using task definition
resource "aws_ecs_service" "api" {
  name            = "${local.prefix}-api"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.api.family
  desired_count   = 1
  #added version of Farget
  platform_version = "1.4.0"
  launch_type      = "FARGATE"

  #for test, upload in public
  network_configuration {
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "proxy"
    container_port   = 8000
  }
}

#define the template with s3 bucket
data "template_file" "ecs_s3_write_policy" {
  template = file("templates/ecs/s3-write-policy.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.app_public_files.arn
  }
}

#create policy from above ecs_s3_write_policy
resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${local.prefix}-AppS3AccessPolicy"
  path        = "/"
  description = "Allow access to the rmmaa app S3 bucket"

  policy = data.template_file.ecs_s3_write_policy.rendered
}

#attach policy to app_iam_role
resource "aws_iam_role_policy_attachment" "ecs_s3_access" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}
