require 'wagn/mods_spec_helper'

def create_page iUrl=nil
    url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
  Card::Env.params[:sourcebox] = 'true'
  sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
  Card::Env.params[:sourcebox] = 'false'

  sourcepage
end


def create_claim name
  Card::Auth.as_bot do
    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card.create! :type=>"Claim", :name=>name, :subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    
  end
end
