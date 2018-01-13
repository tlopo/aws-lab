desc('Invoke terraform with arguments')
task :cli do
  RakeArgvConsumer.consume(Rake::TestTask)
  Terraform.create_config
  success = Docker.run("cd /root/terraform; terraform #{ARGV.join(' ')}")
  raise 'Exit status non zero' unless success
end
