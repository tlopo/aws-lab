require 'io/console'
require 'fileutils'

# Run commands against orchestrator container
class Docker
  AWS_CACHE = "#{PROJECT_DIR}/.aws".freeze
  TF_DIR = "#{PROJECT_DIR}/.terraform".freeze

  def self.run(cmd, terminal = false)
    FileUtils.mkdir_p(AWS_CACHE)
    ts = Time.now.strftime('%s.%N')
    tmpfile = "#{PROJECT_DIR}/.script-#{ts}.sh"
    File.open(tmpfile, 'w+') { |f| f.write(cmd) }
    docker_cmd = [
      'docker run -i --rm',
      "-v #{PROJECT_DIR}/.berkshelf:/root/.berkshelf",
      "-v #{PROJECT_DIR}/.chef:/root/.chef",
      "-v #{PROJECT_DIR}/cookbooks:/root/.chef/cookbooks",
      "-v #{PROJECT_DIR}/.ssh:/root/.ssh",
      "-v #{AWS_CACHE}:/root/.aws",
      "-v #{TF_DIR}:/root/terraform",
      "-v #{tmpfile}:/tmp/#{File.basename(tmpfile)}"
    ]

    ENV.keys.grep(/AWS/).each { |k| docker_cmd << "-e #{k}='#{ENV[k]}'" }

    docker_cmd << '-t' if terminal
    docker_cmd << IMAGE_NAME.to_s
    docker_cmd << %(bash "/tmp/#{File.basename(tmpfile)}")

    Process.wait(fork { exec docker_cmd.join ' ' })
    File.delete(tmpfile)
    $?.exitstatus
  end
end
