# Cucumber tests truncate the test db and reseed with the rake task test:seed
# We have to override that to use Wikirate's special seeding mechanism
Rake::Task["test:seed"].clear
namespace :test do
  desc "Load wikrate's test db dump"
  task seed: :environment do
    Rake::Task["wikirate:test:seed"].invoke
  end
end

