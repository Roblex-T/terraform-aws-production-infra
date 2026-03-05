resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL from app instances only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_db_instance" "db" {
  identifier             = "${var.project_name}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible    = false

  # ✅ THIS makes it Multi-AZ (standby in another AZ)
  multi_az               = true

  skip_final_snapshot    = true
}