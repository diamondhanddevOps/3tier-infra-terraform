#security group for pritunl
resource "aws_security_group" "pritunl-sg" {
  name        = "allow_tls_pritunl"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.vpn_inbound_ports
    content {
      from_port   = ingress.value.internal
      to_port     = ingress.value.external
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.CidrBlock]
    }
  }

  #   ingress {
  #     description      = "TLS from VPC"
  #     from_port        = 22
  #     to_port          = 22
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #   }
  #     ingress {
  #     description      = "TLS from VPC"
  #     from_port        = 80
  #     to_port          = 80
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #   }
  #     ingress {
  #     description      = "TLS from VPC"
  #     from_port        = 443
  #     to_port          = 443
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #   }

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

#pritunl ec2 instance
module "pritunl_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "pritunl"

  ami                    = "ami-0530ca8899fac469f"
  instance_type          = "t3a.micro"
  key_name               = "ayush-squareops"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.pritunl-sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = file("pritunl.sh")

  tags = {
    Terraform   = "true"
    Environment = "stg"
  }
}