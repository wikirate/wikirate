require "wagn/mods_spec_helper"
require_relative "source_helper"
require_relative "../test/seed"

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

include SourceHelper
include SharedData::Samples

def create_claim name, subcards={}
  Card::Auth.as_bot do
    # url = "http://www.google.com/?q=wikirate"
    # sourcepage = create_page url
    Card.create! type_id: Card::ClaimID, name: name,
                 subcards: {
                   "+source" => {
                     content: sample_source.name,
                     type_id: Card::PointerID
                   }
                 }.merge(subcards)
  end
end

def subcards_of_metric_value metric, company, content, year=nil, source=nil
  year ||= "2015"
  source ||= sample_source.name
  content ||= "I'm fine, I'm just not happy."
  {
    "+metric" => { "content" => metric.name },
    "+company" => { "content" => "[[#{company.name}]]", :type_id => Card::PointerID },
    "+value" => { "content" => content, :type_id => Card::PhraseID },
    "+year" => { "content" => year, :type_id => Card::PointerID },
    "+source" => { "content" => "[[#{source}]]\n", :type_id => Card::PointerID }
  }
end

# Usage:
# create_metric type: :researched do
#   Siemens 2015: 4, 2014: 3
#   Apple   2105: 7
# end
def create_metric opts={}, &block
  Card::Auth.as_bot do
    if opts[:name] && opts[:name].to_name.parts.size == 1
      opts[:name] = "#{Card::Auth.current.name}+#{opts[:name]}"
    end
    opts[:name] ||= "TestDesigner+TestMetric"
    Card::Metric.create opts, &block
  end
end

def html_trim str
  s = str.dup
  s.delete!("\r\n")
  s.delete!("\n")
  s.delete!("  ")
  s
end
