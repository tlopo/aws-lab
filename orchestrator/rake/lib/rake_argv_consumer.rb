require 'rake/task'

# Cosumes ARGV for tasks
class RakeArgvConsumer
  def self.consume(app)
    ARGV.each do |arg|
      app.new(arg.to_sym) {}
    end

    ARGV.shift
    ARGV.shift if ARGV[0] == '--'
  end
end
