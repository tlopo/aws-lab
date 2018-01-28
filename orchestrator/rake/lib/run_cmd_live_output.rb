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

    pid = fork do 
      slave.close
      $stdout.reopen master
      exec @cmd
    end
    
    master.close
    slave.each_char {|c| $stdout << c}
    
    Process.wait pid
    $?.exitstatus
  end
end
