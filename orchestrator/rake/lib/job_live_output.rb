require 'pty'
require 'io/console'

# Run a callable with pretty realtime output
class JobLiveOutput
  def initialize(opts = {})
    @opts = opts
  end

  def run(opts = @opts)
    func = opts[:func]
    name = opts[:name]
    out = opts[:out] || STDOUT
    err = opts[:err] || STDERR
    master, slave = PTY.open
    err_read, err_write = IO.pipe
    %i[master slave].each { |e| binding.local_variable_get(e).tap(&:raw!).tap(&:sync) }

    result_r, result_w = IO.pipe
    pid = fork do
      result_r.close
      STDERR.reopen(err_write)
      STDOUT.reopen(master)
      begin
        result = func.call
        Marshal.dump({ result: result, error: nil }, result_w)
      rescue StandardError => e
        Marshal.dump({ result: nil, error: e }, result_w)
      end
    end
    master.close
    result_w.close

    consume_stream(name, slave, out, false)
    consume_stream(name, err_read, err, true)

    result = Marshal.load(result_r.read)

    Process.wait(pid)
    %i[ master slave err_read
        err_write result_r result_w].each { |e| binding.local_variable_get(e).close }
    result
  end

  def format_line(name, line, is_stderr)
    return format("\e[32;1m%<name>15s |\e[0m %<line>s", name: name, line: line) unless is_stderr
    return format("\e[31;1m%<name>15s |\e[0m %<line>s", name: name, line: line) if is_stderr
  end

  def consume_stream(name, read, write, is_stderr)
    Thread.new do
      begin
        read.each_line { |line| write.write(format_line(name, line, is_stderr)) }
      rescue Errno::EIO
        nil
      end
    end
  end
end
