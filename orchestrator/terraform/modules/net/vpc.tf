variable environment { default = "aws-lab" }
variable cidr { default = "10.0.0.0/16" }

resource "aws_vpc" "vpc" {
  enable_dns_hostnames = "true"
  cidr_block = "${var.cidr}"
  tags = {
    Name = "vpc-${var.environment}" 
  }
}
