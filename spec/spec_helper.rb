require "wagn/mods_spec_helper"
require_relative "source_helper"

# require File.expand_path(
#   '../../mod/01_rating/spec/lib/shared_calculation_examples.rb', __FILE__
# )

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

def get_subcards_of_metric_value metric, company, content, year=nil, source=nil
  this_year = year || "2015"
  this_source = source || sample_source.name
  this_content = content || "I'm fine, I'm just not happy."
  {
    "+metric" => { "content" => metric.name },
    "+company" => { "content" => "[[#{company.name}]]",
                    :type_id => Card::PointerID },
    "+value" => { "content" => this_content, :type_id => Card::PhraseID },
    "+year" => { "content" => this_year, :type_id => Card::PointerID },
    "+source" => { "content" => "[[#{this_source}]]\n",
                   :type_id => Card::PointerID }

  }
end

def create_claim_with_url name, url, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page url
    Card.create! type_id: Card::ClaimID, name: name,
                 subcards: {
                   "+source" => {
                     content: "[[#{sourcepage.name}]]",
                     type_id: Card::PointerID
                   }
                 }.merge(subcards)
  end
end

def create_claim name, subcards={}
  Card::Auth.as_bot do
    url = "http://www.google.com/?q=wikirateissocoolandawesomeyouknow"
    sourcepage = create_page url
    Card.create! type_id: Card::ClaimID, name: name,
                 subcards: {
                   "+source" => {
                     content: "[[#{sourcepage.name}]]",
                     type_id: Card::PointerID
                   }
                 }.merge(subcards)
  end
end

# cards only exist in testing db
def sample_note
  Card["Death Star uses dark side of the Force"]
end

def sample_company
  Card["Death Star"]
end

def sample_topic
  Card["Force"]
end

def sample_companies num=1, args={}
  Card.search args.merge(type_id: Card::WikirateCompanyID, limit: num)
end

def sample_topics num=1, args={}
  Card.search args.merge(type_id: Card::WikirateTopicID, limit: num)
end

def sample_analysis
  Card["Death Star+Force"]
end

def sample_metric value_type=:free_text
  metric_names = {
    free_text: "Jedi+Sith Lord in Charge",
    number: "Jedi+deadliness",
    category: "Jedi+disturbances in the Force",
    money: "Jedi+cost of planets destroyed"
  }
  Card[metric_names[value_type]]
end

def sample_project
  Card["Evil Project"]
end

def sample_source
  Card.search(type_id: Card::SourceID, limit: 1).first
end

def sample_metric_value
  Card["Jedi+disturbances_in_the_Force+Death_Star+1977"]
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
