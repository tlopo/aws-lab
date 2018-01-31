desc('Jump o docker bash')
task :bash do
  Docker.run('/bin/bash')
end
