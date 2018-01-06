PROJECT_DIR = __dir__.to_s
RAKE_DIR = File.expand_path "#{PROJECT_DIR}/orchestrator/rake"

require 'logger'
LOGGER = Logger.new STDOUT

require "#{RAKE_DIR}/lib/run_cmd_live_output"
require "#{RAKE_DIR}/lib/docker_run"

DOCKERFILE = File.expand_path "#{RAKE_DIR}/../docker/Dockerfile"
IMAGE_NAME = 'aws-lab-orchestrator'.freeze

task :default do
  puts `rake -sT`
end

Dir.chdir RAKE_DIR
payload = []
Dir.entries(RAKE_DIR).each do |f1|
  next if ['.', '..', 'lib'].include? f1
  next unless File.directory? f1
  payload << "namespace '#{File.basename f1}' do"
  Dir.entries("#{RAKE_DIR}/#{f1}").each do |f2|
    file = "#{RAKE_DIR}/#{f1}/#{f2}"
    payload.push(*File.open(file).readlines) if File.file? file
  end
  payload << 'end'
end
File.open("#{PROJECT_DIR}/.dyn-tasks", 'w+') { |f| f.write payload.join("\n") }
import "#{PROJECT_DIR}/.dyn-tasks"
