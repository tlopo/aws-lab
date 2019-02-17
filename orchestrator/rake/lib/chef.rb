# Class to interact with chef cookbooks
class Chef
  MANIFEST = "#{PROJECT_DIR}/lab.yaml".freeze
  FileUtils.mkdir_p("#{PROJECT_DIR}/.chef")
  FileUtils.mkdir_p("#{PROJECT_DIR}/.berkshelf")

  def self.create_berksfile
    manifest = YAML.safe_load(File.read(MANIFEST))
    berksfile = ["source 'https://supermarket.chef.io'"]
    manifest['chef']['berks'].each do |line|
      berksfile << line
    end
    # File.delete "#{PROJECT_DIR}/.chef/Berksfile.lock"
    # File.delete "#{PROJECT_DIR}/.chef/Berksfile"
    File.open("#{PROJECT_DIR}/.chef/Berksfile", 'w+') { |f| f.puts(berksfile.join("\n")) }
  end

  def self.package_cookbook
    create_berksfile
    Docker.run('cd /root/.chef && berks install && berks package 1.tgz')
    raise 'Failed to package cookbooks' unless $?.success?
  end
end
