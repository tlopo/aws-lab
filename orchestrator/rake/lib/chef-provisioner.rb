#! /usr/bin/env ruby

require 'json'

# install chefdk
# package cookbook
# create nodes.json
# scp cookbook
# provision
class ChefProvisioner
  def provision(vm)
    prepare
    provision_single(vm)
  end

  def provision_single(vm)
    log_level = 'info'
    str = "#{vm}-#{Time.now.strftime('%F_%T.%N')}"
    dst = "/tmp/#{str}"
    runlist = get_runlist(vm)
    script = [
      'set -xe',
      "cd #{dst}/.chef",
      'rpm -q chef || curl -L https://www.opscode.com/chef/install.sh | bash ',
      'sudo mkdir -p /var/chef/nodes',
      '/opt/chef/bin/chef-solo -L /dev/stdout \\',
      " -l #{log_level} -j #{dst}/.chef/nodes.json --recipe-url #{dst}/.chef/1.tgz -o #{runlist}"
    ]
    File.open("#{PROJECT_DIR}/.chef/#{vm}-provision.sh", 'w+') { |f| f.puts(script.join("\n")) }
    SSH.scp(vm, '/root/.chef', dst)
    result = SSH.jump(vm, "sudo bash #{dst}/.chef/#{vm}-provision.sh")
    result
  end

  def get_runlist(vm)
    cfg = MANIFEST['aws']['instances'].find { |e| e['name'] == vm }
    runlist = cfg['chef']['runlist']
    runlist.join(',')
  end

  def prepare
    # package cookbook
    Chef.package_cookbook

    # create nodes.json
    File.open("#{PROJECT_DIR}/.chef/nodes.json", 'w+') do |f|
      f.puts(MANIFEST['chef']['attributes'].to_json)
    end
  end
end
