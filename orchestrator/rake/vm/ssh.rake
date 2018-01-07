desc('jump or execute command on vm')
task :ssh do
  RakeArgvConsumer.consume(Rake::TestTask)
  SSH.jump(*ARGV)
end
