resource "aws_key_pair" "developer" {
  key_name   = "aws-key"
  public_key = "${file("aws-key.pub")}"
}

# # Add 1 EC2 instance in public subnet
 resource "aws_instance" "webservers" {
   count         = 1
   ami           = "ami-5a8da735"
   instance_type = "t2.micro"
   subnet_id     = "${aws_subnet.web_subnets.*.id[count.index]}"

   key_name  = "${aws_key_pair.developer.key_name}"
   user_data = "${file("install_httpd.sh")}"

   vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]

   tags {
     Name = "Webserver"
   }
 }

# Add Security Group for Web servers

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow all inbound http traffic"
  vpc_id      = "${aws_vpc.myapp_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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


# # Add 2 EC2 instance in private subnet
 resource "aws_instance" "privateservers" {
   count         = 2
   ami           = "ami-5a8da735"
   instance_type = "t2.micro"
   subnet_id     = "${aws_subnet.private_subnet.*.id[count.index]}"

   key_name  = "${aws_key_pair.developer.key_name}"
   
   vpc_security_group_ids = ["${aws_security_group.private.id}"]

   tags {
     Name = "private server"
   }
 }

# Add Security Group for private servers

resource "aws_security_group" "private" {
  name        = "private"
  description = "block all inbound traffic"
  vpc_id      = "${aws_vpc.myapp_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}