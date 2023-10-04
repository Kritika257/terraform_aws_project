# AUTHOR: Kritika Shaw

# created vpc
resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
}

# created subnet
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# created internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id
}

# created route table
resource "aws_route_table" "routetab" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# created route table association
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routetab.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.routetab.id
}

# created security group
resource "aws_security_group" "websg" {
  name        = "web"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.mainvpc.id

# inbound rule
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# created bucket
resource "aws_s3_bucket" "s3bucket" {
  bucket = "kritikabucketterrraform"
}
resource "aws_s3_bucket_public_access_block" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id
}

# created instances
resource "aws_instance" "server1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.subnet1.id
  user_data              = base64encode(file("page.sh"))
}

resource "aws_instance" "server2" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.subnet2.id
  user_data              = base64encode(file("page1.sh"))
}

# created load balancer
resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

# created target group for load balancer
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mainvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# attached load balancer with target group 
resource "aws_lb_target_group_attachment" "tga" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.server2.id
  port             = 80
}

# created load balancer listener
resource "aws_lb_listener" "listener" {
  # Other parameters
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# print output for load balancer
output "loadbalancerdns" {
  value = aws_lb.mylb.dns_name
}




