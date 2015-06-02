require 'wagn/mods_spec_helper'

Spork.prefork do
  RSpec.configure do |config|
    config.before(:each) do
      Card::Env[:protocol] = "http://"
      Card::Env[:host] = "wikirate.org"
    end
  end
end

def create_page iUrl=nil, subcards={}
  create_page_with_sourcebox iUrl, subcards,'false'
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

def create_claim_with_url name,url, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page url
    Card.create! :type=>"Claim", :name=>name, 
                 :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}.merge(subcards)    
  end

end

def create_claim name, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card.create! :type=>"Claim", :name=>name, 
                 :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}.merge(subcards)    
  end

end
#cards only exist in testing db
def get_a_sample_claim 
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

def html_trim str
  s = str.dup
  s.delete!("\r\n")
  s.delete!("\n")
  s.delete!("  ")
  s
end

