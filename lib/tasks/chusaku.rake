chusaku_lib = File.expand_path(File.dirname(__FILE__, 2))

desc "Add route annotations to your Rails actions"
task chusaku: :environment do
  require "#{chusaku_lib}/chusaku/cli"

  Chusaku::CLI.new.call(ARGV[2...] || [])
end
