# Class to interact with chef cookbooks
class Chef
  MANIFEST = "#{PROJECT_DIR}/lab.yaml".freeze
  FileUtils.mkdir_p("#{PROJECT_DIR}/.chef")
  FileUtils.mkdir_p("#{PROJECT_DIR}/.berkshelf")

  def self.create_berksfile
    manifest = YAML.safe_load(File.read(MANIFEST))
    berksfile = "source 'https://supermarket.chef.io'"
    manifest['chef']['berks'].each do |cb|
      berksfile += %(\ncookbook '#{cb['cookbook']}', git:'#{cb['git']}', tag: '#{cb['tag']}')
    end
    # File.delete "#{PROJECT_DIR}/.chef/Berksfile.lock"
    File.open("#{PROJECT_DIR}/.chef/Berksfile", 'w+') { |f| f.puts(berksfile) }
  end

  def self.package_cookbook
    create_berksfile
    Docker.run('cd /root/.chef && berks install && berks package 1.tgz')
  end
end
