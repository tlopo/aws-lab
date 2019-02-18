require 'yaml'
require 'English'

# Terraform helper
class Terraform
  TF_DIR = "#{PROJECT_DIR}/.terraform".freeze
  def self.create_config
    FileUtils.mkdir_p(TF_DIR.to_s)
    FileUtils.rm_rf("#{TF_DIR}/modules")
    FileUtils.cp_r("#{PROJECT_DIR}/orchestrator/terraform/modules", TF_DIR)
    gen_key
    pub_key = File.read("#{PROJECT_DIR}/.ssh/id_rsa.pub").strip
    key_name = 'aws-lab'
    cfg = <<-CFG.gsub(/^ {6}/, '')
      provider "aws" {
        region = "#{MANIFEST['aws']['region']}"
        version = "1.6"
      }

      variable "environment" {}
      variable "cidr" {}

      resource "aws_key_pair" "#{key_name}" {
        key_name = "#{key_name}"
        public_key = "#{pub_key}"
      }

      module "net" {
        source = "./modules/net"
        environment = "${var.environment}"
        cidr = "${var.cidr}"
      }
    CFG

    MANIFEST['aws']['instances'].each do |i|
      vm = get_vm_cfg(
        net_id: '${module.net.net_id}',
        type: i['type'],
        name: i['name'],
        ami: i['ami'],
        private_ip: i['private_ip'],
        tags: i['tags'],
        key_name: key_name
      )
      cfg = "#{cfg}\n#{vm}"
    end

    vars = <<-VARS.gsub(/^ {6}/, '')
      environment = "#{MANIFEST['environment']}"
      cidr = "#{MANIFEST['aws']['vpc']['cidr']}"
    VARS

    File.open("#{TF_DIR}/lab.tf", 'w+') { |f| f.write(cfg) }
    File.open("#{TF_DIR}/terraform.tfvars", 'w+') { |f| f.write(vars) }
    Docker.run('cd /root/terraform && terraform init')
  end

  def self.gen_key
    dir = "#{PROJECT_DIR}/.ssh"
    FileUtils.mkdir_p(dir)
    file = "#{dir}/id_rsa"
    return if File.exist?(file)

    cmd = "ssh-keygen -f #{file} -P ''"
    `#{cmd}`
    raise "Failed to create '#{file}'" unless $CHILD_STATUS.success?
  end

  def self.get_vm_cfg(opts = {})
    net_id = opts[:net_id]
    type = opts[:type]
    name = opts[:name]
    key_name = opts[:key_name]
    private_ip = opts[:private_ip]
    ami = opts[:ami] || ''
    tags = opts[:tags]
    cfg = [
      %Q[module "vm-#{name}" {],
      '  source = "./modules/vm"',
      '  environment = "${var.environment}"',
      %Q[  net_id = "#{net_id}"],
      %Q[  name = "#{name}"]
    ]
    tags = tags.map { |k, v| %Q[    #{k} = "#{v}"] }.join "\n"

    cfg << %Q[  ami = "#{ami}"] unless ami.empty?
    cfg << %Q[  type = "#{type}"] unless type.empty?
    cfg << %Q[  key_name = "#{key_name}"] unless key_name.empty?
    cfg << %Q[  private_ip = "#{private_ip}"] unless private_ip.empty?
    cfg << "  tags = {\n#{tags}\n  }" unless tags.empty?
    cfg << '}'
    cfg.join "\n"
  end
end
