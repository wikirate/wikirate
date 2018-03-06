module Cardio
  def self.seed_test_db
    system "env RAILS_ENV=test bundle exec rake wikirate:test:seed"
  end
end
# Before("@background-jobs, @delayed-jobs, @javascript") do
#   Card[:all, :script].update_machine_output
#   Card[:all, :style].update_machine_output
# end
