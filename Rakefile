PROJECT_DIR = __dir__.to_s
RAKE_DIR = File.expand_path "#{PROJECT_DIR}/orchestrator/rake"

require 'logger'
require 'rake/testtask'
require 'pretty_multitask'
LOGGER = Logger.new STDOUT
LOGGER.level = Logger::DEBUG

require "#{RAKE_DIR}/lib/docker_run"
require "#{RAKE_DIR}/lib/terraform"
require "#{RAKE_DIR}/lib/ssh"
require "#{RAKE_DIR}/lib/chef"
require "#{RAKE_DIR}/lib/chef-provisioner"
require "#{RAKE_DIR}/lib/rake_argv_consumer"

DOCKERFILE = File.expand_path "#{RAKE_DIR}/../docker/Dockerfile"
IMAGE_NAME = 'aws-lab-orchestrator'.freeze
MANIFEST = YAML.safe_load(File.read("#{PROJECT_DIR}/lab.yaml"), [], [], true)

# ChefProvisioner.provision 'lab-vm-01'; exit 1

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
