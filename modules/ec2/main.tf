data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# App instances SG: allow HTTP ONLY from ALB, SSH from your IP, egress anywhere.
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "App instances SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    echo "<h1>${var.project_name} - $(hostname)</h1>" > /var/www/html/index.html
    systemctl start httpd
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }
}

# ✅ Correct way to connect ALB target group to ASG (no unknown instance IDs issue)
resource "aws_autoscaling_attachment" "asg_to_tg" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = var.target_group_arn
}