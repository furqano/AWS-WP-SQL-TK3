provider "aws"{
  region = "ap-south-1"
  profile= "fate"
}

#     create vpc

resource "aws_vpc" "main"{
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = "true"
 
  tags ={
    Name = "fatevpc"
  }
}


#	subnets for vpc
#	subnet 1

resource "aws_subnet" "public_subnet"{
  vpc_id  =  "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"


 tags = {
   Name = "public-subnet-1a"
  }
}

#	subnet 2

resource "aws_subnet" "private_subnet" {
  vpc_id  =  "${aws_vpc.main.id}"
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-south-1b"


  tags = {
    Name = "private-subnet-1b"
  }
}


#	internet gateway

resource "aws_internet_gateway" "InternetGW" {
  vpc_id = "${aws_vpc.main.id}"


  tags = {
    Name = "fate_gateway"
  }
}


#	routing table

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.main.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.InternetGW.id}"
  }
  tags = {
   Name = "myroute"
  }
}
resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "private-c" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table.id
}


#	   Security group

resource "aws_security_group" "security" {
  name        = "fatesecurity"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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


resource "aws_security_group" "security" {
  name        = "fatesecurity"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"
 ingress {
    description = "mysql"
    from_port   = 3360
    to_port     = 3360
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



#	AWS Instance 

resource "aws_instance" "fateos1" {
	ami = "ami-052c08d70def0ac62"
	instance_type = "t2.micro"
	key_name = "eks"
	vpc_security_group_ids = [aws_security_group.security1.id]
        subnet_id = "${aws_subnet.public_subnet.id}"
tags = {
	Name = "WP"
	}
   }

resource "aws_instance" "fateos2" {
	ami = "ami-08706cb5f68222d09"
	instance_type = "t2.micro"
	key_name = "eks"
	vpc_security_group_ids = [aws_security_group.security2.id , aws_security_group.security1.id]
        subnet_id = "${aws_subnet.private_subnet.id}"
tags = {
	Name = "SQL"
	
   }
}