# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateClaimCount do
  def create_page iUrl=nil
      url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    Card::Env.params[:sourcebox] = 'true'
    sourcepage = Card.create! :type_id=>Card::WebpageID,:subcards=>{ '+Link' => {:content=> url} }
    Card::Env.params[:sourcebox] = 'false'

    
    sourcepage
  end
  before do
    login_as 'joe_user' 
  end
  it "returns correct claim count" do
    company1 = Card.create! :name=>"company1",:type=>"company"
  

    topic1 = Card.create! :name=>"topic1",:type=>"topic"
  

    ct1 = Card.create! :name=>"#{company1.name}+#{topic1.name}",:type=>"analysis"
  

    sourcepage = create_page 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'

    #test single source
    claim1 = Card.create! :type=>"Claim", :name=>"claim1" ,:subcards=>{ 
      '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
      '+companies' => {:content=>"[[#{company1.name}]]"},
      '+topics' => {:content=>"[[#{topic1.name}]]"}
    }    
    claim2 = Card.create! :type=>"Claim", :name=>"claim2" ,:subcards=>{ 
      '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
      '+companies' => {:content=>"[[#{company1.name}]]"},
      '+topics' => {:content=>"[[#{topic1.name}]]"}
    }    
  
    html = render_card :raw,{:name=>ct1.name+"+claim count"}
    
    expect(html).to eq("2")
    expect(Card.claim_counts ct1.key).to eq(2)

  end


end
