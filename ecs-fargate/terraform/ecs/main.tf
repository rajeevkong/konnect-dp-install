
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.initials}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "${var.initials}-ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect = "Allow",
        Resource = [
          "${var.kong_cluster_cert_arn}",
          "${var.kong_cluster_cert_key_arn}"
        ]
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.initials}-kong-gateway"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "${var.initials}-ecs-cluster"
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.initials}-ecs-sg"
  description = "Allow traffic to ECS containers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port       = 8100
    to_port         = 8100
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.initials}-lb-sg"
  description = "Allow traffic to the Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs_lb" {
  name               = "${var.initials}-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.initials}-ecs-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/status"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
    port                = "8100"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.initials}-kong-gateway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  depends_on               = [aws_cloudwatch_log_group.ecs_log_group]

  container_definitions = jsonencode([{
    name      = "kong-gateway"
    image     = "kong/kong-gateway:3.7.0.0"
    essential = true
    portMappings = [
      {
        containerPort = 8000
        hostPort      = 8000
      },
      {
        containerPort = 8443
        hostPort      = 8443
      },
      {
        containerPort = 8100
        hostPort      = 8100
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "${var.initials}-kong-gateway"
      }
    }
    environment = [
      {
        name  = "KONG_ROLE"
        value = "data_plane"
      },
      {
        name  = "KONG_DATABASE"
        value = "off"
      },
      {
        name  = "KONG_VITALS"
        value = "off"
      },
      {
        name  = "KONG_CLUSTER_MTLS"
        value = "pki"
      },
      {
        name  = "KONG_CLUSTER_CONTROL_PLANE"
        value = var.kong_cluster_control_plane
      },
      {
        name  = "KONG_CLUSTER_SERVER_NAME"
        value = var.kong_cluster_server_name
      },
      {
        name  = "KONG_CLUSTER_TELEMETRY_ENDPOINT"
        value = var.kong_cluster_telemetry_endpoint
      },
      {
        name  = "KONG_CLUSTER_TELEMETRY_SERVER_NAME"
        value = var.kong_cluster_telemetry_server_name
      },
      {
        name  = "KONG_LUA_SSL_TRUSTED_CERTIFICATE"
        value = "system"
      },
      {
        name  = "KONG_KONNECT_MODE"
        value = "on"
      },
      {
        name  = "KONG_STATUS_LISTEN"
        value = "0.0.0.0:8100"
      }
    ]
    secrets = [
      {
        name      = "KONG_CLUSTER_CERT"
        valueFrom = var.kong_cluster_cert_arn
      },
      {
        name      = "KONG_CLUSTER_CERT_KEY"
        valueFrom = var.kong_cluster_cert_key_arn
      }
    ]
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${var.initials}-kong-gateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "kong-gateway"
    container_port   = 8000
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_lb_listener.http]
}
