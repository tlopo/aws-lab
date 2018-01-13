desc('Invoke terraform apply -auto-aprove')
task :apply do
  RakeArgvConsumer.consume(Rake::TestTask)
  Terraform.create_config
  success = Docker.run("cd /root/terraform; terraform apply -auto-approve")
  raise 'Exit status non zero' unless success
end
