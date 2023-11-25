#S3 Bucket
resource "aws_s3_bucket" "s3_bkt" {
  bucket = "s3bucket12092"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

#IAM EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#EC2 Instance
resource "aws_instance" "ec2instance" {
  count                  = var.counter
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_80n443.id]
}

#IAM
resource "aws_iam_user" "usr1" {
  name = "usr1"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

#IAM POLICY ADD S3
resource "aws_iam_user_policy" "user_policy" {
  name = "testpolicy"
  user = aws_iam_user.usr1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        # Resource = "${aws_s3_bucket.s3_bkt.arn}"
        # # Resource = [var.resource]
        Resource = "*"
      },
    ]
  })
}

#Security Group
resource "aws_security_group" "allow_80n443" {
  name   = "allow_80n443"
#   vpc_id = "${aws_vpc.main.id}"
  

  ingress {
    description = "TCP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_80n443"
  }
}