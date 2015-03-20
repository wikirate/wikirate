# -*- encoding : utf-8 -*-

describe Card::Set::Type::Claim do
  before do
    login_as 'joe_user' 
  end
  def create_page iUrl=nil
    url = iUrl||'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'
    create_page_with_sourcebox url,{},'true'
 
  end

  it "should handle too long claim" do
    card = Card.new(   :type=>"Claim", :name=>"2"*101 )
    expect(card).not_to be_valid
    expect(card.errors).to have_key(:claim)
    expect(card.errors[:claim].first).to eq("is too long (100 character maximum)")
  end
  
  it "handles normal claim creation" do
    #create the testing webpage first
    claim_name = "2"*100
    sourcepage = create_page 

    #test single source
    card = Card.new :type=>"Claim", :name=>claim_name ,:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    
    expect(card).to be_valid

    card = Card.new :type=>"Claim", :name=>claim_name ,:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]\r\n[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}
    expect(card).to be_valid

  end

  it "requires +source card " do
    fake_pagename = "Page-1"
    url = "[[#{fake_pagename}]]"

    # nth here
    card = Card.new(   :type=>"Claim", :name=>"2"*100)
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("is empty")
    #without type
    card = Card.new(   :type=>"Claim", :name=>"2"*100,:subcards=>{ '+source' => {:content=> url}})
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("#{fake_pagename} does not exist")

    #with a non exisiting url in any webpage
    card = Card.new(   :type=>"Claim", :name=>"2"*100 ,:subcards=>{ '+source' => {:content=> url,:type_id=>Card::PointerID}})
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("#{fake_pagename} does not exist")


    page = create_page
    card = Card.new(   :type=>"Claim", :name=>"2"*100,:subcards=>{ '+source' => {:content=> "[[Home]]",:type_id=>Card::PointerID}})
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("Home is not a valid Source Page")
  end

  describe "views" do 
    before do
      login_as 'joe_user'
      @claim_name = "testing claim"
      @sourcepage = create_page 
      @sample_claim = get_a_sample_claim
    end

    it "show help text and claim counting for claim name when creating claim" do
      claim_card  = card = Card.new :type=>"Claim"
      help_content = "Add a Claim about a Company"
      claim_help_card = Card.fetch "claim+*type+*add help",:new=>{:content=>help_content}
      if claim_help_card.real?
        help_content = claim_help_card.content
      else
        claim_help_card.save
      end
      html = claim_card.format._render_name_formgroup :new=>true
      expect(html).to include("claim-counting")
      expect(html).to include(help_content)

    end

    it "shows sample_citation view" do 
      claim_card  = create_claim @claim_name,{}
      #%{ <div class="sample-citation">#{ render :tip, :tip=>tip }</div> }
      expect(claim_card.format.render_sample_citation).to include(%{<div class="sample-citation">})
      expect(claim_card.format.render_sample_citation).to include("#{@claim_name} {{#{@claim_name}|cite}}")
    end

    describe "tip view" do
      context "when the user did not signed in" do 
        it "shows nothing" do
          claim_card = Card.create :type=>"Claim", :name=>@claim_name ,:subcards=>{'+source' => {:content=>"[[#{@sourcepage.name}]]",:type_id=>Card::PointerID}}    
          login_as 'Anonymous'
          expect(claim_card.format.render_tip).to eq('')
        end
      end
      context "when there is no topic " do 
        it "shows tip about adding topic" do
          claim_card = Card.create :type=>"Claim", :name=>@claim_name ,:subcards=>{ '+company'=>'apple','+source' => {:content=>"[[#{@sourcepage.name}]]",:type_id=>Card::PointerID}}    
          expect(claim_card.format.render_tip).to include('improve this claim by adding a topic.')
        end
      end
      context "when there is no company " do 
        it "shows tip about adding company" do
          claim_card = Card.create :type=>"Claim", :name=>@claim_name ,:subcards=>{ '+topic'=>'natural resource use','+source' => {:content=>"[[#{@sourcepage.name}]]",:type_id=>Card::PointerID}}    
          expect(claim_card.format.render_tip).to include('improve this claim by adding a company.')
        end
      end
      context "when company and topic exist" do 
        context "when  card.analysis_names.size > cited_in.size " do 
          it "shows tip about citing this claim in related articles" do
            claim_card = create_claim @claim_name,{'+company'=>'apple','+topic'=>'natural resource use'}
            expect(claim_card.format.render_tip).to include('cite this claim in related articles.')
          end
        end
        context "when card.analysis_names.size <= cited_in.size " do 
          it "shows nothing" do
            new_company_name = "Orange"
            new_topic_name = "Doctor"
            new_company = Card.create :type=>"Company", :name=>new_company_name
            new_topic = Card.create :type=>"Topic", :name=>new_topic_name
            claim_card = create_claim @claim_name,{'+company'=>new_company_name,'+topic'=>new_topic_name}
            expect(claim_card.format.render_tip).to include('')
          end
        end
      end
    end
    it "shows titled view with voting" do
      expect(@sample_claim.format.render_titled).to eq(@sample_claim.format.render_titled_with_voting)
    end
    context "when in open views" do
      it "shows header with voiting" do
        html = @sample_claim.format.render_open
        vote_html = @sample_claim.format.subformat( @sample_claim.vote_count_card ).render_details
        expect(html_trim(html)).to include(html_trim(vote_html))
      end
    end
    it "shows the link for view \"missing\"" do
      claim_card = get_a_sample_claim
      html = claim_card.format.render_missing
      expect(html).to eq(claim_card.format.render_link )
    end
     it "show clipboard view" do 
      claim_card = get_a_sample_claim
      expected_html = %{<i class="fa fa-clipboard claim-clipboard" id="copy-button" title="copy claim citation to clipboard" data-clipboard-text="#{claim_card.name} {{#{claim_card.name}|cite}}"></i>}
      expect(claim_card.format.render_clipboard).to include(expected_html)
       
    end
  end
  it "returns correct analysis_names " do

    real_company = get_a_sample_company
    real_topic = get_a_sample_topic

    another_real_company = Card.create :name=>"CW TV",:type_id=>Card::WikirateCompanyID
    another_real_topic = Card.create :name=>"Should we have supernatural season 11?",:type_id=>Card::WikirateTopicID

    claim_card = create_claim "testclaim",{'+company' => {:content=>"[[#{another_real_company.name}]]\r\n[[#{real_company.name}]]"},'+topic' => {:content=>"[[#{another_real_topic.name}]]\r\n[[#{real_topic.name}]]"}}

    expect(claim_card.analysis_names).to eq(["CW TV+Should we have supernatural season 11?", "CW TV+Force", "Death Star+Should we have supernatural season 11?", "Death Star+Force"])
  end
end
