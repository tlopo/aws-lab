require 'logger'
require 'English'
require 'io/console'
require 'pty'

# Run a command with connected STDOUT and STDERR
class RunCmdLiveOutput
  LOGGER ||= Logger.new(STDERR)
  def initialize(cmd)
    @cmd = cmd
  end

  def run(cmd = @cmd)
    LOGGER.debug("Running [#{cmd}]")
    master, slave = PTY.open
    slave.raw!
    master.raw!
    master.sync
    slave.sync 
    $stdout.sync 

    pid = fork do 
      slave.close
      $stdout.reopen master
      exec @cmd
    end
    
    master.close
    begin
      slave.each_char {|c| $stdout << c}
    rescue Errno::EIO
    end    
    Process.wait pid
    $?.exitstatus
  end
end
