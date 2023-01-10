# security group for backend alb 
resource "aws_security_group" "nodejs-alb-sg" {
  name        = "allow_tls_alb_nodejs"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# alb for backend nodejs
module "nodejs-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "nodejs-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
  security_groups = [aws_security_group.nodejs-alb-sg.id]

  target_groups = [
    {
      name_prefix      = "nodejs"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200,404"
      }

      # targets = {
      #   my_target = {
      #     target_id = module.nodejs_instance.id
      #     port = 3000
      #   }
      # }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:us-west-2:421320058418:certificate/73b9c44b-3865-4f0a-b508-dc118857ae2e"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "stg"
  }
}

# module "records" {
# source  = "terraform-aws-modules/route53/aws//modules/records"
# version = "~> 2.0"

# zone_name = rtd.squareops.co.in

# records = [
#   {
#     name    = "nodejs"
#     type    = "A"
#     alias   = {
#       name    = "dualstack.nodejs-alb-1685595372.us-west-2.elb.amazonaws.com"
#       zone_id = "Z1H1FL5HABSF5"
#     }
#   }
# ]
# }  