module Cardio
  # override seeding method
  module Utils
    def self.seed_test_db
      system "env RAILS_ENV=test bundle exec rake wikirate:test:seed"
    end
  end
end
