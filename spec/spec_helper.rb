require 'wagn/mods_spec_helper'

# require File.expand_path(
#   '../../mod/01_rating/spec/lib/shared_calculation_examples.rb', __FILE__
# )

Spork.prefork do
  RSpec.configure do |config|
    config.before(:each) do
      Card::Env[:protocol] = 'http://'
      Card::Env[:host] = 'wikirate.org'
    end
  end
end

def create_page iUrl=nil, subcards={}
  create_page_with_sourcebox iUrl, subcards, 'true'
end

def create_page_with_sourcebox iUrl=nil, subcards={}, sourcebox=nil
  Card::Auth.as_bot do
    url = iUrl || 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    _sourcebox = sourcebox || 'true'
    Card::Env.params[:sourcebox] = _sourcebox
    sourcepage = Card.create!(
      type_id: Card::SourceID,
      subcards: { '+Link' => { content: url } }.merge(subcards)
    )
    Card::Env.params[:sourcebox] = 'false'

    sourcepage
  end
end

def create_claim_with_url name, url, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page url
    Card.create! type_id: Card::ClaimID, name: name,
                 subcards: {
                   '+source' => {
                     content: "[[#{sourcepage.name}]]",
                     type_id: Card::PointerID
                   }
                 }.merge(subcards)
  end
end

def create_claim name, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card.create! type_id: Card::ClaimID, name: name,
                 subcards: { '+source' => {
                   content: "[[#{sourcepage.name}]]",
                   type_id: Card::PointerID }
                 }.merge(subcards)
  end
end

# cards only exist in testing db
def get_a_sample_claim
  Card['Death Star uses dark side of the Force']
end

def get_a_sample_company
  Card['Death Star']
end

def get_a_sample_topic
  Card['Force']
end

def get_a_sample_analysis
  Card['Death Star+Force']
end

def get_a_sample_metric
  Card['Jedi+disturbances in the Force']
end

def get_a_sample_source
  Card.search(type_id: Card::SourceID, limit: 1).first
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
    opts[:name] ||= 'TestDesigner+TestMetric'
    Card::Metric.create opts, &block
  end
end

def html_trim str
  s = str.dup
  s.delete!("\r\n")
  s.delete!("\n")
  s.delete!('  ')
  s
end
