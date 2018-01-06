require 'open3'
require 'logger'
require 'English'

# Run a command with connected STDOUT and STDERR
class RunCmdLiveOutput
  LOGGER ||= Logger.new(STDERR)
  def initialize(cmd, i = $stdin, o = $stdout, _e = $stderr)
    `uname | grep -qi darwin`
    @cmd = if $CHILD_STATUS.success?
             "script -q /dev/null #{cmd}"
           else
             "script -q -e -c '#{cmd}' /dev/null"
           end
    @i = i
    @o = o
    @e = $stderr
  end

  def run(cmd = @cmd)
    LOGGER.debug("Running [#{cmd}]")
    # exit
    `stty raw -echo`
    Open3.popen3(cmd) do |i, o, e, t|
      is_running = lambda do |pid|
        begin
          Process.getpgid(pid)
          return true
        rescue Errno::ESRCH
          return false
        end
      end

      Thread.new { o.each_char { |char| @o.write(char) } }
      Thread.new { e.each_char { |char| @e.write(char) } }
      tin = Thread.new { @i.each_char { |char| i.write(char) } }

      while is_running.call(t.pid) do sleep(0.3) end
      tin.terminate
      `stty echo -raw > /dev/null 2>&1`
      t.value.to_i.zero?
    end
  end
end
