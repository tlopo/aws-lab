require 'io/console'
require 'fileutils'

# Run commands against orchestrator container
class Docker
  AWS_CACHE = "#{PROJECT_DIR}/.aws".freeze
  TF_DIR = "#{PROJECT_DIR}/.terraform".freeze

  def self.run(cmd)
    rows, cols = IO.console.winsize
    cmd = "stty columns #{cols} rows #{rows}\n#{cmd}"
    FileUtils.mkdir_p(AWS_CACHE)
    ts = Time.now.strftime('%s.%N')
    tmpfile = "#{PROJECT_DIR}/.script-#{ts}.sh"
    File.open(tmpfile, 'w+') { |f| f.write(cmd) }
    docker_cmd = [
      'docker run -it --rm',
      "-v #{PROJECT_DIR}/.berkshelf:/root/.berkshelf",
      "-v #{PROJECT_DIR}/.chef:/root/.chef",
      "-v #{PROJECT_DIR}/.ssh:/root/.ssh",
      "-v #{AWS_CACHE}:/root/.aws",
      "-v #{TF_DIR}:/root/terraform",
      "-v #{tmpfile}:/tmp/#{File.basename(tmpfile)}",
      IMAGE_NAME.to_s,
      %(bash "/tmp/#{File.basename(tmpfile)}")
    ]
    result = RunCmdLiveOutput.new(docker_cmd.join(' ')).run
    File.delete(tmpfile)
    result
  end
end
