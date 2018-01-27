#! /usr/bin/env ruby

require 'json'

# install chefdk
# package cookbook
# create nodes.json
# scp cookbook
# provision
class ChefProvisioner
  MANIFEST = "#{PROJECT_DIR}/lab.yaml".freeze

  def self.provision(vm)
    log_level = 'info'
    str = Time.now.strftime('%F_%T.%N')
    dst = "/tmp/#{str}"
    runlist = get_runlist(vm)
    script = [
      'set -x',
      "cd #{dst}/.chef",
      'rpm -q chef || curl -L https://www.opscode.com/chef/install.sh | bash ',
      'sudo mkdir -p /var/chef/nodes',
      '/opt/chef/bin/chef-solo -L /dev/stdout \\',
      " -l #{log_level} -j $PWD/nodes.json --recipe-url $PWD/1.tgz -o #{runlist}"
    ]
    prepare
    File.open("#{PROJECT_DIR}/.chef/provision.sh", 'w+') { |f| f.puts(script.join("\n")) }
    SSH.scp(vm, '/root/.chef', dst)
    SSH.jump(vm, "sudo bash #{dst}/.chef/provision.sh")
  end

  def self.get_runlist(vm)
    manifest = YAML.safe_load(File.read(MANIFEST))
    cfg = manifest['aws']['instances'].find { |e| e['name'] == vm }
    runlist = cfg['chef']['runlist']
    runlist.join(',')
  end

  def self.prepare
    manifest = YAML.safe_load(File.read(MANIFEST))
    # package cookbook
    Chef.package_cookbook

    # create nodes.json
    File.open("#{PROJECT_DIR}/.chef/nodes.json", 'w+') do |f|
      f.puts(manifest['chef']['attributes'].to_json)
    end
  end
end
