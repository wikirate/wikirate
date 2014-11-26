
require File.expand_path('../../self/webpage_spec',  __FILE__)

describe Card::Set::All::Wikirate do
  describe "claim count things" do 

    it "returns correct claim count" do 
      #create Company
      #create topic
      #create a few claims related to this company+topic

      #calculate claim count
      company1 = Card.create! :name=>"company1",:type=>"company"
      company2 = Card.create! :name=>"company2",:type=>"company"

      topic1 = Card.create! :name=>"topic1",:type=>"topic"
      topic2 = Card.create! :name=>"topic2",:type=>"topic"

      ct1 = Card.create! :name=>"#{company1.name}+#{topic1.name}",:type=>"analysis"
      ct2 = Card.create! :name=>"#{company1.name}+#{topic2.name}",:type=>"analysis"
      ct3 = Card.create! :name=>"#{company2.name}+#{topic1.name}",:type=>"analysis"
      ct4 = Card.create! :name=>"#{company2.name}+#{topic2.name}",:type=>"analysis"

      sourcepage = create_page_with_sourcebox 'http://www.google.com/?q=wikirateissocoolandawesomeyouknow'

      #test single source
      claim1 = Card.create! :type=>"Claim", :name=>"claim1" ,:subcards=>{ 
        '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
        '+companies' => {:content=>"[[#{company1.name}]]\n[[#{company2.name}]]"},
        '+topics' => {:content=>"[[#{topic1.name}]]"}
      }    
      claim2 = Card.create! :type=>"Claim", :name=>"claim2" ,:subcards=>{ 
        '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
        '+companies' => {:content=>"[[#{company2.name}]]"},
        '+topics' => {:content=>"[[#{topic1.name}]]"}
      }    
      claim3 = Card.create! :type=>"Claim", :name=>"claim3" ,:subcards=>{ 
        '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
        '+companies' => {:content=>"[[#{company1.name}]]"},
        '+topics' => {:content=>"[[#{topic2.name}]]"}
      }    
      claim4 = Card.create! :type=>"Claim", :name=>"claim4" ,:subcards=>{ 
        '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID},
        '+companies' => {:content=>"[[#{company1.name}]]\n[[#{company2.name}]]"},
        '+topics' => {:content=>"[[#{topic1.name}]]\n[[#{topic2.name}]]"}
      } 
      
      expect(Card.claim_counts "#{ct1.key}").to eq(2)
      expect(Card.claim_counts "#{ct2.key}").to eq(2)
      expect(Card.claim_counts "#{ct3.key}").to eq(3)
      expect(Card.claim_counts "#{ct4.key}").to eq(1)
      expect(Card.claim_counts "#{company1.key}").to eq(3)
      expect(Card.claim_counts "#{company2.key}").to eq(3)
      expect(Card.claim_counts "#{topic1.key}").to eq(3)
      expect(Card.claim_counts "#{topic2.key}").to eq(2)
    end


  end

  describe "while showing view" do

    it "renders edits_by view" do 
      html = render_card :edits_by,{:name=>"Home"}
      expect(html).to include(render_card_with_args :shorter_search_result,{:name=>"Home+*editor"},{},{:item=>:link})
    end

    it "renders titled_with_edits view" do
      html = render_card :titled_with_edits,{:name=>"Home"}
      expect(html).to include(render_card :header,{:name=>"Home"})
      expect(html).to include(render_card :edits_by,{:name=>"Home"})
    end

    it "should always show the help text " do
      
      #render help text of source page
      #create a page with help text
      login_as "WagnBot" 
      basic = Card.create :type=>"Basic", :name=>"testhelptext",:content=>"<p>hello test case</p>"
      help_card = Card.create :type=>"Basic", :name=>"testhelptext+*self+*help",:content=>"Can I help you?"
      expect(render_card :name_fieldset,{:name=>"testhelptext"}).to include("Can I help you?")

    end
    it "show \"\" when for cite view other than in html format" do 
      html = render_card :cite,{:name=>"test1"},{:format=>:json}
      expect(html).to eq("")
    end
    it "return html for an existing card for modal view" do
      login_as "WagnBot"
      card = Card.create! :name=>"test_basic",:type=>"html",:content=>"Hello World"
      Card::Env.params[:show_modal] = card.name
      html = render_card :modal,{:name=>card.name}
      expect(html).to eq("<div class='modal-window'>#{ render_card :core,{:name=>card.name} } </div>")

    end
    it "return \"\" for an non existing card or nil card in arg for modal view" do
      #nil card in arg
      html = render_card :modal,{:name=>"test1"}
      expect(html).to eq("")

      Card::Env.params[:show_modal] = "test1"
      html = render_card :modal,{:name=>"test1"}
      expect(html).to eq("")
    end

    it "shows correct cite number and content for claim cite view" do 
      #create 2 claims
      #create an card with claim cite contents
      #check the number and the content
      sourcepage = create_page_with_sourcebox nil,{},'false'
      claim1 = Card.create! :type=>"Claim", :name=>"test1",:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    
      claim2 = Card.create! :type=>"Claim", :name=>"test2",:subcards=>{ '+source' => {:content=>"[[#{sourcepage.name}]]",:type_id=>Card::PointerID}}    
      content=""
      for i in 0..10
        if i%2==0
          content+="{{test1|cite}}"
        else
          content+="{{test2|cite}}"
        end
      end
      html = render_card :content,{:name=>"test_basic",:content=>content}
      for i in 1..11
        if (i-1)%2==0
          expect(html).to include(%{<sup><a class="citation" href="test_basic#test1">#{i}</a></sup>})  
        else
          expect(html).to include(%{<sup><a class="citation" href="test_basic#test2">#{i}</a></sup>})  
        end
      end
    end
    it "shows correct html for the menu_link view" do
      html = render_card :menu_link,{:name=>"non-exisiting-card"}
      expect(html).to eq('<a class="fa fa-pencil-square-o"></a>')
    end
    it "shows empty string for not real card for raw_or_blank view" do
      html = render_card :raw_or_blank,{:name=>"non-exisiting-card"}
      expect(html).to eq('')
    end
    it "renders raw for real card for raw_or_blank view" do
      html = render_card :raw_or_blank,{:name=>"home"}
      expect(html).to eq(render_card :raw,{:name=>"home"})
    end
  end
  describe "while viewing id_atom in json format" do
    it "includes id" do
      login_as 'WagnBot' 
      search_card = Card.create! :type=>"search",:content=>"{\"type\":\"company\"}",:name=>"id_atom_test"
      Card::Env.params[:item] = 'id_atom'
      result = search_card.format( :format=>:json)._render(:content) 
      card_array = result[:card][:value]
      # binding.pry
      card_array.each do |card|
        card.should have_key :id
      end
      
    end
    it "handle param:start " do
      login_as 'WagnBot' 
      start = 20140601000000
      search_card = Card.create! :type=>"search",:content=>"{\"type\":\"company\"}",:name=>"id_atom_test"
      Card::Env.params[:item] = 'id_atom'
      Card::Env.params["start"] = start
      wql = {:type=>"Company"}
      company_cards_list = Card.search wql
      valid_company_cards = Hash.new
      company_cards_list.each do |card|
        if card.updated_at.strftime("%Y%m%d%H%M%S").to_i >= start 
          valid_company_cards[card.id]=card.name
        end
      end
      result = search_card.format( :format=>:json).render(:content)
      card_array = result[:card][:value]
      card_array.each do |card|
        card.should have_key :id
        expect(valid_company_cards.has_key? card[:id]).to be true
      end
    end
  end
  describe "view of shorter_search_result" do
    def create_dump_card number
      cards = Array.new
      for i in 0..number-1 
        Card.create! :name=>"testcard#{i+1}",:type=>"Basic"
        cards.push "\"testcard#{i+1}\""
      end
      cards.join(',')
    end
    before do
      login_as 'WagnBot' 
      @search_card_name = "_search_test"
    end
    it "handles only 1 result" do
      cards_name = create_dump_card 1
      search_card = Card.create! :name=>@search_card_name,:type=>"search",:content=>"{\"name\":#{cards_name}}"
      expected_content = search_card.item_cards(:limit=>0)[0].format.render(:link)
      expect(render_card :shorter_search_result,:name=>@search_card_name).to eq(expected_content)
    end
    it "handles only 2 results" do
      cards_name = create_dump_card 2
      search_card = Card.create! :name=>@search_card_name,:type=>"search",:content=>"{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(:limit=>0)
      expected_content = result_cards[0].format.render(:link)+" and "+result_cards[1].format.render(:link)
      expect(render_card :shorter_search_result,:name=>@search_card_name).to eq(expected_content)
    end
    it "handles only 3 results" do
      cards_name = create_dump_card 3
      search_card = Card.create! :name=>@search_card_name,:type=>"search",:content=>"{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(:limit=>0)
      expected_content = result_cards[0].format.render(:link)+" , "+result_cards[1].format.render(:link)+" and "+result_cards[2].format.render(:link)
      expect(render_card :shorter_search_result,:name=>@search_card_name).to eq(expected_content)    
    end
    it "handles more than 3 results" do
      cards_name = create_dump_card 10
      search_card = Card.create! :name=>@search_card_name,:type=>"search",:content=>"{\"name\":[\"in\", #{cards_name}]}"
      result_cards = search_card.item_cards(:limit=>0)      
      expected_content = result_cards[0].format.render(:link)+" , "+result_cards[1].format.render(:link)+" , "+result_cards[2].format.render(:link)+" and <a class=\"known-card\" href=\"#{search_card.format.render(:url)}\"> 7 others</a>"
      expect(render_card :shorter_search_result,:name=>@search_card_name).to eq(expected_content)    
     
    end
  end
  
  
end