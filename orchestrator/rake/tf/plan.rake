desc('Invoke terraform plan')
task :plan do
  RakeArgvConsumer.consume(Rake::TestTask)
  Terraform.create_config
  success = Docker.run('cd /root/terraform; terraform plan')
  raise 'Exit status non zero' unless success
end
