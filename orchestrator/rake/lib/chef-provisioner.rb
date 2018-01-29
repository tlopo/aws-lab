#! /usr/bin/env ruby

require 'json'

# install chefdk
# package cookbook
# create nodes.json
# scp cookbook
# provision
class ChefProvisioner
  MANIFEST = "#{PROJECT_DIR}/lab.yaml".freeze
  TTY_SETTINGS = `stty -g`

  def provision(vm)
    prepare
    provision_single(vm)
  end

  def provision_single(vm)
    `stty #{TTY_SETTINGS}`
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
    `stty #{TTY_SETTINGS}`
    result = SSH.jump(vm, "sudo bash #{dst}/.chef/#{vm}-provision.sh")
    `stty #{TTY_SETTINGS}`
    result
  end

  def provision_all
    LOGGER.info('Started provision')
    start_time = Time.now
    threads = []
    result = {}
    SSH.vms_get.each do |vm|
      vm_name = vm['primary']['attributes']['tags.Name']
      func = proc { provision_single vm_name }
      threads.push((Thread.new do
        Thread.current[:name] = vm_name
        Thread.current[:exit_status] = JobLiveOutput.new(name: vm_name, func: func).run
      end))
    end
    threads.each do |t|
      t.join
      result[t[:name]] = t[:exit_status]
    end
    end_time = Time.now
    etime = end_time - start_time
    etime = format('%02d:%02d:%02d', etime / 3600 % 24, etime / 60 % 60, etime % 60)

    `stty #{TTY_SETTINGS}`
    result.each_key do |k|
      msg = "Provision failed for #{k}, exit status: #{result[k][:result]}"
      LOGGER.error(msg) if result[k][:result].to_i > 0
    end
    LOGGER.info("Finished provision, elapsed time: #{etime}")
  end

  def get_runlist(vm)
    manifest = YAML.safe_load(File.read(MANIFEST))
    cfg = manifest['aws']['instances'].find { |e| e['name'] == vm }
    runlist = cfg['chef']['runlist']
    runlist.join(',')
  end

  def prepare
    manifest = YAML.safe_load(File.read(MANIFEST))
    # package cookbook
    Chef.package_cookbook

    # create nodes.json
    File.open("#{PROJECT_DIR}/.chef/nodes.json", 'w+') do |f|
      f.puts(manifest['chef']['attributes'].to_json)
    end
  end
end
