require "colorize"

namespace :deckorate do
  desc "pull from decko repository to vendor/decko and commit"
  task :decko_tick do
    _task, branch = ARGV
    branch ||= "deckorate"
    psystem "cd vendor/decko && git pull origin #{branch}"
    psystem "git commit vendor/decko -m 'decko tick'"
    exit
  end

  def psystem cmd
    puts cmd.green
    system cmd
  end
end
