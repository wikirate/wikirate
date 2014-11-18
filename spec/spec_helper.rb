require 'wagn/mods_spec_helper'

def create_page iUrl=nil, subcards={},sourcebox
  Card::Auth.as_bot do
    url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    _sourcebox = sourcebox||'true'
    Card::Env.params[:sourcebox] = _sourcebox
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }.merge(subcards)
    Card::Env.params[:sourcebox] = 'false'

    sourcepage
  end
end

def create_claim name, subcards={}
  Card::Auth.as_bot do
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card.create! :type=>"Claim", :name=>name, 
                 :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}.merge(subcards)    
  end
end