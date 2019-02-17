desc('Build orchestrator docker image')
task :build do
  Dir.chdir("#{File.dirname(DOCKERFILE)}/")
  cmd = "docker build  -t #{IMAGE_NAME}:0.0.1 -t #{IMAGE_NAME}:latest ."
  Process.wait(fork { exec cmd })
  LOGGER.info('Image successfully built') if $?.success?
  raise 'Failed to build image' unless $?.success?
end
