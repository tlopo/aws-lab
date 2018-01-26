desc('Invoke terraform destroy -force')
task :destroy do
  RakeArgvConsumer.consume(Rake::TestTask)
  Terraform.create_config
  success = Docker.run('cd /root/terraform; terraform destroy -force')
  raise 'Exit status non zero' unless success
end
