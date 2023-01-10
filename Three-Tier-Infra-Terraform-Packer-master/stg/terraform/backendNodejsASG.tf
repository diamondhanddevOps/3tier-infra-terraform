#security group for backend nodejs
resource "aws_security_group" "nodejs-sg" {
  name        = "allow_tls_nodejs"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.pritunl-sg.id]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.nodejs-alb-sg.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "nodejs-asg"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  target_group_arns         = module.nodejs-alb.target_group_arns
  # Launch template
  launch_template_name        = "nodejs-asg-temp"
  launch_template_description = "Launch template for nodejs"
  update_default_version      = true

  image_id                    = "ami-0c9d1caab790128ec"
  instance_type               = "t3a.micro"
  key_name                    = "ayush-squareops"
  create_iam_instance_profile = false
  iam_instance_profile_name   = "CodeDeploynodejsAppEC2"
  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.nodejs-sg.id]
    }
  ]

  tags = {
    Environment = "stg"
  }
}
