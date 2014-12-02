# -*- encoding : utf-8 -*-

describe Card::Set::Right::FilterSearch do
  
  before do
    login_as 'joe_user' 
  end
  describe "views" do
    context "when rendering filter_form" do
      it "includeds required fieldsets" do
        filter_search_card = Card.fetch "Claim+filter_search"
        format = filter_search_card.format
        html = format.render_filter_form

        html = html.squish

        sort_html = %{<fieldset >
          <legend>
            <h2>Sort</h2>

          </legend>
          <div class="editor"><select id="sort" name="sort"><option value="recent" selected="selected">Most Recent</option>
          <option value="important">Most Important</option></select></div>
          </fieldset>
          }
        claimed_html = %{<fieldset >
          <legend>
            <h2>Claimed</h2>

          </legend>
          <div class="editor"><select id="claimed" name="claimed"><option value="all" selected="selected">All</option>
          <option value="yes">Yes</option>
          <option value="no">No</option></select></div>
          </fieldset>
          }
        cited_html = %{
            <fieldset >
          <legend>
            <h2>Cited</h2>

          </legend>
          <div class="editor"><select id="cited" name="cited"><option value="all" selected="selected">All</option>
          <option value="yes">Yes</option>
          <option value="no">No</option></select></div>
          </fieldset>
          }

        expect(html).to include(sort_html.squish)
        expect(html).to include(claimed_html.squish)
        expect(html).to include(cited_html.squish)
        expect(html).to include(format.render_company_fieldset.squish)
        expect(html).to include(format.render_topic_fieldset.squish)
        expect(html).to include(format.render_tag_fieldset.squish)

        expect(html.start_with?(%{<form action="/Claim" method="GET">})).to be true
      end
      it "shows Source for action 'Page'" do 
        filter_search_card = Card.fetch "Page+filter_search"
        format = filter_search_card.format
        html = format.render_filter_form
        html = html.squish
        expect(html.start_with?(%{<form action="/Source" method="GET">})).to be true
      end
      context "when rendering with parameters" do
        before do
          @company_card = get_a_sample_company
          @topic_card = get_a_sample_topic
          @filter_search_card = Card.fetch "Claim+filter_search"
          
          @new_company = Card.create :name=>"test_company",:type_id=>Card::WikirateCompanyID
          @new_topic = Card.create :name=>"test_topic",:type_id=>Card::WikirateTopicID

          @new_company1 = Card.create :name=>"test_company1",:type_id=>Card::WikirateCompanyID
          @new_topic1 = Card.create :name=>"test_topic1",:type_id=>Card::WikirateTopicID
          @claim_card = create_claim "whateverclaim",{"+company"=>{:content=>"[[#{@new_company.name}]]\r\n[[#{@new_company1.name}]]"},"+topic"=>{:content=>"[[#{@new_topic.name}]]\r\n[[#{@new_topic1.name}]]"},"+tag"=>{:content=>"[[thisisatestingtag]]\r\n[[thisisalsoatestingtag]]"}}      
        end
        context "when including company and topic, tag parameters" do
          it do
          # html = filter_search_card.format.render_filter_form
            Card::Env.params[:topic] = [@new_topic.name,@new_topic1.name]
            Card::Env.params[:company] = [@new_company.name,@new_company1.name]
            Card::Env.params[:tag] = "thisisatestingtag"

            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do
              with_tag('div',:class=>"search-result-list") do
                with_tag('div',:class=>"search-result-item item-content") do
                  with_tag('div',:with=>{:id=>"whateverclaim"})
                end
              end
            end
          end
        end
        context "when condition does not match" do
          it "uses non related tag" do
             Card::Env.params[:tag] = "nonexisitingtag"

            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do    
              without_tag('div',:with=>{:id=>"whateverclaim"})
            end
          end
          it "uses non related company" do
             Card::Env.params[:company] = "Iamnoangel"
            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do    
              without_tag('div',:with=>{:id=>"whateverclaim"})
            end
          end
          it "uses non related topic" do
             Card::Env.params[:topic] = "Iamnodemon"
            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do    
              without_tag('div',:with=>{:id=>"whateverclaim"})
            end
          end
          it "is cited" do
            Card::Env.params[:cited] = "yes"
            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do    
              without_tag('div',:with=>{:id=>"whateverclaim"})
            end
          end
          it "is not cited" do
            Card::Env.params[:cited] = "no"
            new_analysis = Card.create :name=>"#{@new_company.name}+#{@new_topic.name}",:type_id=>Card::WikirateAnalysisID
            new_article = Card.create :name=>"#{@new_company.name}+#{@new_topic.name}+#{Card[:wikirate_article].name}",:type_id=>Card::BasicID,:content=>"asdsad#{@claim_card.default_citation}"

            html = Card["Claim"].format.render_core
            expect(html).to have_tag('div',:with=>{:id=>"Claim+filter_search"}) do    
              without_tag('div',:with=>{:id=>"whateverclaim"})
            end
          end
        end
        context "when sorting" do
          before do 
            @claim_card1 = create_claim_with_url "whateverclaimrecent","http://www.google.com/yo",{"+company"=>{:content=>"[[#{@new_company.name}]]\r\n[[#{@new_company1.name}]]"},"+topic"=>{:content=>"[[#{@new_topic.name}]]\r\n[[#{@new_topic1.name}]]"},"+tag"=>{:content=>"[[thisisatestingtag]]\r\n[[thisisalsoatestingtag]]"}}      
          end
          it "is most recent" do
            html = Card["Claim"].format.render_core
            expect(html.index("whateverclaimrecent")).to be <= html.index("whateverclaim")
          end
          it "is most important" do

            Card::Auth.as_bot do
              vc = @claim_card1.vote_count_card
              vc.vote_up
              vc.save!
            end

            Card::Env.params[:sort] == 'important'
            html = Card["Claim"].format.render_core
            expect(html.index("whateverclaimrecent")).to be >= html.index("whateverclaim")
          end
        end
      end
    end
  end
end