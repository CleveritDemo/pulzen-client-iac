resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "Allow traffic from ALB to ECS containers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vnet_cidr
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create subnets in 2 AZs for container
resource "aws_subnet" "container_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.container_subnet_cidr_a
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "container-subnet-a"
  }
}

resource "aws_subnet" "container_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.container_subnet_cidr_b
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "container-subnet-b"
  }
}

# Create subnets in 2 AZs for DB
resource "aws_subnet" "db_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr_a
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "db-subnet-a"
  }
}

resource "aws_subnet" "db_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr_b
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "db-subnet-b"
  }
}

# Internet Gateway for public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# Route table for public subnets (containers)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# Associate route table with container subnets
resource "aws_route_table_association" "container_subnet_a_association" {
  subnet_id      = aws_subnet.container_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "container_subnet_b_association" {
  subnet_id      = aws_subnet.container_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# MongoDB-compatible database: Amazon DocumentDB
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "${var.app_name}-docdb-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_a.id, aws_subnet.db_subnet_b.id]
}

resource "aws_docdb_cluster_parameter_group"  "docdb_cluster_param_group" {
  name   = "${var.app_name}-docdb-cluster-param-group"
  family = "docdb5.0"

  parameter {
    name  = "tls"
    value = "disabled" # tls allowed values are: disabled,enabled,tls1.2+,tls1.3+
  }

  tags = {
    Name = "${var.app_name}-docdb-cluster-param-group"
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.app_name}-cluster"
  engine                  = "docdb"
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  backup_retention_period = 1
  preferred_backup_window = "04:00-06:00"
  skip_final_snapshot     = true
  apply_immediately       = true
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  port                    = 27017
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_cluster_param_group.name
  
  tags = {
    Name = "${var.app_name}-cluster"
  }
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  count              = 1
  identifier         = "${var.app_name}-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class = var.docdb_instance_class
  apply_immediately  = true
}

# Security Group
resource "aws_security_group" "docdb_sg" {
  name        = "${var.app_name}-docdb-sg"
  description = "Allow access to DocumentDB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id] # Allow traffic from ECS SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster for Fargate
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-cluster"
}

locals {
  app_env_vars = [
    {
      name  = "MONGODB"
      value = "mongodb://${var.db_username}:${var.db_password}@${aws_docdb_cluster.docdb.endpoint}:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
    },
    {
      name  = "SPRING_DATA_MONGODB_AUTO_INDEX_CREATION"
      value = "true"
    },
    {
      name  = "DEBUG"
      value = "true"
    }
  ]

  # Append custom environment variables (if any) from the variable `var.env_vars`
  app_env_vars_with_custom = concat(local.app_env_vars, [
    for k, v in var.env_vars : {
      name  = k
      value = v
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = 8192

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.container_image
      cpu       = 2048
      memory    = 8192
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = local.app_env_vars_with_custom

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.location
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Application Load Balanced Fargate Service
resource "aws_lb" "app_lb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.container_subnet_a.id, aws_subnet.container_subnet_b.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.app_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1

  network_configuration {
    subnets = [aws_subnet.container_subnet_a.id, aws_subnet.container_subnet_b.id]
    security_groups  = [aws_security_group.ecs_sg.id] 
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.app_name
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.app_listener]
}