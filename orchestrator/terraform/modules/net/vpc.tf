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

output "vpc-id" { value = "${aws_vpc.vpc.id}" }
output "net-id" { value = "${aws_subnet.default.id}" }
