require 'json'
# SSH in on vms
class SSH
  TF_STATE_FILE = "#{PROJECT_DIR}/.terraform/terraform.tfstate".freeze
  SSH_OPTS = [
    '-o BatchMode=yes',
    '-o LogLevel=error',
    '-o GlobalKnownHostsFile=/dev/null',
    '-o UserKnownHostsFile=/dev/null',
    '-o StrictHostKeyChecking=false'
  ].freeze
  def self.show
    puts(format("%20s %20s %20s\n", 'Name', 'Public IP', 'Private IP'))
    vms_get.each do |vm|
      public_ip = vm['primary']['attributes']['public_ip']
      private_ip = vm['primary']['attributes']['private_ip']
      name = vm['primary']['attributes']['tags.Name']
      printf "%20s %20s %20s\n", name, public_ip, private_ip
    end
  end

  def self.vms_get
    vms = []
    tf_state = YAML.safe_load(File.read(TF_STATE_FILE))
    tf_state['modules'].each do |m|
      next unless m['resources']
      m['resources'].each do |r|
        vms << r[1] if r[0] == 'aws_instance.vm'
      end
    end
    vms
  end

  def self.jump(*args)
    user = 'ec2-user'
    host = args[0]
    args.shift
    public_ip = ip_get(host)

    raise "Host '#{host}' not found" if public_ip.nil?

    cmd = "ssh -l #{user} #{SSH_OPTS.join(' ')} #{public_ip} #{args.join(' ')}"
    Docker.run(cmd)
  end

  def self.scp(host, src, dst)
    user = 'ec2-user'
    ['host','src','dst'].each do |var|
      raise "'#{var}' must be specified" unless binding.local_variable_get var
    end
    cmd = "rsync -av -e 'ssh -l #{user} #{SSH_OPTS.join(' ')}' '#{src}' '#{ip_get(host)}:#{dst}'"
    Docker.run(cmd)
  end

  def self.ip_get(host)
    public_ip = nil
    vms_get.each do |vm|
      ip = vm['primary']['attributes']['public_ip']
      public_ip = ip if vm['primary']['attributes']['tags.Name'] == host
    end
    public_ip
  end
end
