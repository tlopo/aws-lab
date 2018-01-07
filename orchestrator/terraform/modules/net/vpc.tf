variable environment { default = "aws-lab" }
variable cidr { default = "10.0.0.0/16" }

resource "aws_vpc" "vpc" {
  enable_dns_hostnames = "true"
  cidr_block = "${var.cidr}"
  tags = {
    Name = "vpc-${var.environment}-vpc" 
  }
}

resource "aws_subnet" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr}"
  tags = {
    Name = "#{var.environment}-net"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    self = true
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-sg-default"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = "${aws_subnet.default.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

output "vpc-id" { value = "${aws_vpc.vpc.id}" }
output "net-id" { value = "${aws_subnet.default.id}" }
