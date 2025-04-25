# Define ECS Cluster
resource "aws_ecs_cluster" "example" {
  name = "my-ecs-cluster"
}

# Define IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# IAM Role Policy Attachment for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ECS Task Definition using Docker Image
resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "strapi-container"
    image     = "209378969061.dkr.ecr.us-east-1.amazonaws.com/strapi-deployment:latest" # Make sure to use your actual ECR image URL
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/strapi-service" # Log group name
        "awslogs-region"        = "us-east-1"           # Region
        "awslogs-stream-prefix" = "strapi"              # Prefix for log streams
      }
    }
  }])
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-security-group"
  description = "Allow inbound traffic on port 1337 and 80"

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    from_port   = 80
    to_port     = 80
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

# Application Load Balancer (ALB)
resource "aws_lb" "strapi_alb" {
  name                       = "strapi-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ecs_security_group.id]
  subnets                    = var.subnet_ids # Dynamic subnets from variable
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "strapi_target_group" {
  name        = "strapi-target-group"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # 👈 This line is the fix

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# ✅ ADD LISTENER BELOW TARGET GROUP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_target_group.arn
  }
}

# ECS Service (Fargate)
resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids # Dynamic subnets from variable
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_target_group.arn
    container_name   = "strapi-container"
    container_port   = 1337
  }
}
