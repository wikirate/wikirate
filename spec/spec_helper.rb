require "decko/mods_spec_helper"
require_relative "source_helper"
require_relative "answer_helper"

# # TODO: move most or all of these to default location in mod and load implicitly
# require_relative "../mod/wikirate_caching/spec/support/cached_count_shared_examples"
# require_relative "../mod/badges/spec/support/badges_shared_examples"
# require_relative "../mod/badges/spec/support/badge_count_shared_examples"
# require_relative "../mod/badges/spec/support/award_badges_shared_examples"
# require_relative "../mod/badges/spec/support/award_answer_create_badges_shared_examples"
# require_relative "../mod/badges/spec/support/award_answer_badges_shared_examples"
# require_relative "../mod/profiles/spec/support/report_query_shared_examples"
# require_relative "../mod/researched_metrics/spec/support/value_type_shared_examples"

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before do
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
    end
    config.example_status_persistence_file_path = "spec/examples.txt"
  end
end

RSpec::Core::ExampleGroup.include SourceHelper
RSpec::Core::ExampleGroup.include AnswerHelper
RSpec::Core::ExampleGroup.include SharedData::Samples
RSpec::Core::ExampleGroup.extend SharedData::Samples::ClassMethods
