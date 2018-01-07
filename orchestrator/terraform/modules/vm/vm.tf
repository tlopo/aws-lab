data "aws_ami" "ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

variable "type" { default = "t2.micro" }
variable "net_id" {}
variable "environment" {}
variable "name" {}

resource "aws_instance" "vm" { 
  ami = "${data.aws_ami.ami.id}"
  instance_type = "${var.type}"
  subnet_id = "${var.net_id}"
  tags = {
    Name = "${var.name}"
  }
}

output "public_ip"  { value = "${aws_instance.vm.public_ip}"}
