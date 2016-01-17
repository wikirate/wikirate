require 'wagn/mods_spec_helper'

Spork.prefork do
  RSpec.configure do |config|
    config.include RSpecHtmlMatchers
    config.before(:each) do
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
    end
  end
end

def create_page iUrl=nil, subcards={}
  create_page_with_sourcebox iUrl, subcards,'true'
end

def create_page_with_sourcebox iUrl=nil, subcards={},sourcebox=nil
  Card::Auth.as_bot do
    url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    _sourcebox = sourcebox||'true'
    Card::Env.params[:sourcebox] = _sourcebox
    sourcepage = Card.create! :type_id=>Card::SourceID,:subcards=>{ '+Link' => {:content=> url} }.merge(subcards)
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
  [:link, :file, :text].each do |key|
    next unless args[key]
    content_key = ( key == :file ? :file : :content)
    res[:subcards]["+#{key.to_s.capitalize}"][content_key] = args[key]
    res[:subcards]["+#{source_type_name}"] = {}
    res[:subcards]["+#{source_type_name}"][:content] = "[[#{key}]]"
  end
  res
end

def create_claim_with_url name,url, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page url
    Card.create! :type_id=>Card::ClaimID, :name=>name,
                 :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}.merge(subcards)
  end

end

def create_claim name, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card.create! :type_id=>Card::ClaimID, :name=>name,
                 :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}.merge(subcards)
  end

end
#cards only exist in testing db
def get_a_sample_note
  Card["Death Star uses dark side of the Force"]
end

def get_a_sample_company
  Card["Death Star"]
end

def get_a_sample_topic
  Card["Force"]
end

def get_a_sample_analysis
  Card["Death Star+Force"]
end

def get_a_sample_metric
  Card["Jedi+disturbances in the Force"]
end

def get_a_sample_source
  Card.search(type_id: Card::SourceID, limit: 1).first
end

def html_trim str
  s = str.dup
  s.delete!("\r\n")
  s.delete!("\n")
  s.delete!("  ")
  s
end

