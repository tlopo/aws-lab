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
    log_level = 'debug'
    str = Time.now.strftime('%F_%T.%N')
    dst = "/tmp/#{str}"
    script = [
      'set -x',
      "cd #{dst}/.chef", 
      'rpm -q chef || {curl -L https://www.opscode.com/chef/install.sh | sudo bash}',
      'sudo mkdir -p /var/chef/nodes; cat nodes.json; ls -ltr',
      "/opt/chef/bin/chef-solo -L /dev/stdout -l #{log_level} -j $PWD/nodes.json --recipe-url $PWD/1.tgz -o k8s-cb::default"  
    ]
    File.open("#{PROJECT_DIR}/.chef/provision.sh",'w+'){|f| f.puts script.join("\n")}
    SSH.scp vm, '/root/.chef', dst
    SSH.jump vm, "sudo bash #{dst}/.chef/provision.sh"
  end

  def self.prepare(vm)
    manifest = YAML.safe_load File.read MANIFEST
    # package cookbook 
    Chef.package_cookbook

    # create nodes.json
    File.open("#{PROJECT_DIR}/.chef/nodes.json",'w+') do |f|
      f.puts manifest['chef']['attributes'].to_json   
    end

  end
  
end