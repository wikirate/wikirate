require "decko/mods_spec_helper"
require_relative "source_helper"
require_relative "answer_helper"

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before(:each) do
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

