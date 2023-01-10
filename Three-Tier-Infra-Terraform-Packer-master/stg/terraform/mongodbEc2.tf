#security group for mongodb database
resource "aws_security_group" "mongo-sg" {
  name        = "allow_tls_mongo"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "TLS from VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pritunl-sg.id]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description     = "TLS from VPC"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.nodejs-sg.id]
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

# mongo db cluster with 3 replicas
module "mongodb_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["mongo-pri-ayush", "mongo-sec1-ayush", "mongo-sec2-ayush"])

  name = "instance-${each.key}"

  ami                    = "ami-0530ca8899fac469f"
  instance_type          = "t3a.micro"
  key_name               = "ayush-squareops"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.mongo-sg.id]
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = <<EOF
#!/bin/bash
apt-get update
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
sudo apt install mongodb-org -y
sudo systemctl start mongod
EOF

  tags = {
    Terraform   = "true"
    Environment = "stg"
  }
}