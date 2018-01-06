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

      module "net" {
        source = "./modules/net"
      }
    CFG
    File.open("#{TF_DIR}/lab.tf", 'w+') { |f| f.write(cfg) }
    Docker.run('cd /root/terraform && terraform init')
  end
end
