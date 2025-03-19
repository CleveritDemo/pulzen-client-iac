# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/20"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.location}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.location}a"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# DocumentDB Cluster
resource "aws_docdb_subnet_group" "docdb_subnet" {
  name       = "docdb-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]
}

resource "aws_docdb_cluster" "mongo" {
  cluster_identifier = "docdb-${var.app_name}"
  master_username    = var.db_username
  master_password    = var.db_password
  engine             = "docdb"
  skip_final_snapshot = true
  db_subnet_group_name = aws_docdb_subnet_group.docdb_subnet.name

  tags = var.project_labels
}

resource "aws_docdb_cluster_instance" "mongo_instance" {
  count              = 1
  identifier         = "docdb-${var.app_name}-instance"
  cluster_identifier = aws_docdb_cluster.mongo.id
  instance_class     = "db.r5.large"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-ecs-cluster"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "8192"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}"
      image     = var.container_image
      cpu       = 2048
      memory    = 8192
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = concat([
        for env_var in var.env_vars :
        {
          name  = env_var.name
          value = env_var.value
        }
      ], [
        {
          name  = "MONGODB_URI"
          value = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.mongo.endpoint}:27017/?ssl=true&retryWrites=false"
        },
        {
          name = "SPRING_DATA_MONGODB_AUTO_INDEX_CREATION"
          value = "true"
        },
        {
          name  = "DEBUG"
          value = "false"
        }
      ])
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${var.app_name}"
    container_port   = 8080
  }
}

# Security group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id]
  security_groups    = [aws_security_group.ecs_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.app_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# App Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# App Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu_scaling" {
  name                   = "cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace      = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value           = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown      = 300
    scale_out_cooldown     = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_scaling" {
  name                   = "memory-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace      = "ecs"
  target_tracking_scaling_policy_configuration {
    target_value           = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown      = 300
    scale_out_cooldown     = 300
  }
}
