require 'wagn/mods_spec_helper'

# require File.expand_path(
#   '../../mod/01_rating/spec/lib/shared_calculation_examples.rb', __FILE__
# )

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before(:each) do
      Card::Env[:protocol] = 'http://'
      Card::Env[:host] = 'wikirate.org'
    end
  end
end

def get_subcards_of_metric_value metric, company, content, year, source
  this_year = year || '2015'
  this_source = source || 'http://www.google.com/?q=everybodylies'
  this_content = content || "I'm fine, I'm just not happy."
  {
    '+metric' => { 'content' => metric.name },
    '+company' => { 'content' => "[[#{company.name}]]",
                    :type_id => Card::PointerID },
    '+value' => { 'content' => this_content, :type_id => Card::PhraseID },
    '+year' => { 'content' => this_year, :type_id => Card::PointerID },
    '+source' => { 'subcards' => {
      'new source' => {
        '+Link' => { 'content' => this_source, 'type_id' => Card::PhraseID }
      }
    }
  } }
end

def create_page iUrl=nil, subcards={}
  create_page_with_sourcebox iUrl, subcards, 'true'
end

def create_page_with_sourcebox iUrl=nil, subcards={}, sourcebox=nil
  Card::Auth.as_bot do
    url = iUrl || 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    tmp_sourcebox = sourcebox || 'true'
    Card::Env.params[:sourcebox] = tmp_sourcebox
    sourcepage = Card.create! type_id: Card::SourceID,
                              subcards: {
                                '+Link' => { content: url }
                              }.merge(subcards)
    Card::Env.params[:sourcebox] = 'false'

    sourcepage
  end
end

def create_link_source url
  create_source link: url
end

def create_source args
  Card.create source_args(args)
end

def source_args args
  res = {
    type_id: Card::SourceID,
    subcards: {
      '+Link' => {},
      '+File' => { type_id: Card::FileID },
      '+Text' => { type_id: Card::BasicID, content: '' }
    }
  }
  source_type_name = Card[:source_type].name
  add_source_type args, res, source_type_name
  res
end

def add_source_type args, res, source_type_name
  [:link, :file, :text].each do |key|
    next unless args[key]
    content_key = (key == :file ? :file : :content)
    res[:subcards]["+#{key.to_s.capitalize}"][content_key] = args[key]
    res[:subcards]["+#{source_type_name}"] = {}
    res[:subcards]["+#{source_type_name}"][:content] = "[[#{key}]]"
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
                 subcards: {
                   '+source' => {
                     content: "[[#{sourcepage.name}]]",
                     type_id: Card::PointerID }
                 }.merge(subcards)
  end
end

# cards only exist in testing db
def get_a_sample_note
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
