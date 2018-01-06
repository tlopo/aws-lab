desc('Configure aws credentials')
task :config do
  RunCmdLiveOutput.new('whoami').run
end
