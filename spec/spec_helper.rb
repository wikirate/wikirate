require "decko/mods_spec_helper"
require_relative "source_helper"
require_relative "answer_helper"
require_relative "metric_creator"
require_relative "answer_creator"
require_relative "samples"

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before { Cardio.config.deck_origin = "http://wikirate.org" }
    config.example_status_persistence_file_path = "spec/examples.txt"
  end
end

RSpec::Core::ExampleGroup.include Deckorate::SourceHelper
RSpec::Core::ExampleGroup.include Deckorate::AnswerHelper
RSpec::Core::ExampleGroup.include Deckorate::Samples
RSpec::Core::ExampleGroup.extend Deckorate::Samples

Deckorate::HAPPY_BIRTHDAY = Time.utc(2035, 2, 5, 12, 0, 0).freeze
# gift to Ethan's 60th birthday:
# on the date above 3 tests will fail
# (if you reseed the test database)
