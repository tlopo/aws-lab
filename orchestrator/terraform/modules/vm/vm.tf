data "aws_ami" "ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
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

variable "ami" { default = "" } 
variable "type" { default = "t2.micro" }
variable "private_ip" { default = "" }
variable "net_id" {}
variable "environment" {}
variable "name" {}
variable "key_name" {}
variable "tags" { default = {}  }

resource "aws_instance" "vm" { 
  ami = "${var.ami != "" ? var.ami : data.aws_ami.ami.id}"
  associate_public_ip_address = true
  instance_type = "${var.type}"
  subnet_id = "${var.net_id}"
  key_name = "${var.key_name}"
  private_ip = "${var.private_ip}"
  source_dest_check = false
  tags = "${merge( var.tags, map("Name", var.name))}" 
}

output "public_ip"  { value = "${aws_instance.vm.public_ip}"}
