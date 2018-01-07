require 'yaml'

# Terraform helper
class Terraform
  TF_DIR = "#{PROJECT_DIR}/.terraform".freeze
  MANIFEST = YAML.safe_load(File.read("#{PROJECT_DIR}/lab.yaml"))
  def self.create_config
    FileUtils.mkdir_p(TF_DIR.to_s)
    FileUtils.rm_rf("#{TF_DIR}/modules")
    FileUtils.cp_r("#{PROJECT_DIR}/orchestrator/terraform/modules", TF_DIR)
    cfg = <<-CFG.gsub(/^ {6}/, '')
      provider "aws" {
        region = "#{MANIFEST['aws']['region']}"
        version = "1.6"
      }

      variable "environment" {}
      variable "cidr" {}

      module "net" {
        source = "./modules/net"
        environment = "${var.environment}"
        cidr = "${var.cidr}"
      }
    CFG

    MANIFEST['aws']['instances'].each do |i|
      vm = get_vm_cfg(
        net_id: '${module.net.net_id}',
        type: (i['type']).to_s,
        name: (i['name']).to_s
      )
      p [vm]
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

  def self.get_vm_cfg(opts = {})
    net_id = opts[:net_id]
    type = opts[:type]
    name = opts[:name]
    <<-CFG.gsub(/^ {6}/, '')
      module "vm-#{name}" {
        source = "./modules/vm"
        environment = "${var.environment}"
        net_id = "#{net_id}"
        name = "#{name}"
        type = "#{type}"
      }
    CFG
  end
end
