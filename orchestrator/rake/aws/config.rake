desc('Configure aws credentials')
task :config do
  Docker.run('aws configure')
end

desc('Configure aws credentials')
task :describe_instances do
  Docker.run('aws ec2 describe-instances')
end
