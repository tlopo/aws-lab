desc('Build orchestrator docker image if not already build')
task :build do
  success = RunCmdLiveOutput.new("docker images | grep -q #{IMAGE_NAME}").run
  if success == false
    LOGGER.info('Building docker image')
    Dir.chdir("#{RAKE_DIR}/../docker")
    cmd = "docker build  -t #{IMAGE_NAME}:0.0.1 -t #{IMAGE_NAME}:latest ."
    built = RunCmdLiveOutput.new(cmd).run
    LOGGER.info('Success') if built
    raise 'Failed to build image' unless built
  else
    LOGGER.info('Image already exists')
  end
end

desc('Build docker image')
task :build_force do
  p 'hi'
  Dir.chdir("#{File.dirname(DOCKERFILE)}/")
  cmd = "docker build  -t #{IMAGE_NAME}:0.0.1 -t #{IMAGE_NAME}:latest ."
  success = RunCmdLiveOutput.new(cmd).run
  LOGGER.info('Image successfully built') if success
  raise 'Failed to build image' unless success
end
