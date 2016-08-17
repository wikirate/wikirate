# cucumber test will keep truncating the test db
# Wagn will try to run the db:fixtures:load to reseed the db
# for wikirate, we have to restore from the dumped test db
# reseeding from the live may take too much time and
# some data only exists in development, which will cause
# insufficient data in the reseed
Rake::Task["db:fixtures:load"].clear
namespace :db do
  namespace :fixtures do
    desc "Load fixtures into the current environment's database. "\
         "Load specific fixtures using FIXTURES=x,y"
    task load: :environment do
      system "env RAILS_ENV=test bundle exec rake wikirate:test:seed"
    end
  end
end
