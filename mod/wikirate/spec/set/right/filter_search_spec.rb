# -*- encoding : utf-8 -*-

describe Card::Set::Right::FilterSearch do

  before do
    login_as "joe_user"
  end
  describe "views" do
    context "when rendering filter_form" do
      it "includes required formgroups" do
        filter_search_card = Card[:claim].fetch :trait=>:filter_search
        format = filter_search_card.format
        html = format.render_filter_form

        html = html.squish

        expect(html).to have_tag("div",:with=>{:class=>"editor"}) do
          with_tag "select", :with=>{:id=>"sort"} do
            with_tag "option", :with=>{:value=>"important",:selected=>"selected"},:text=>"Most Important"
            with_tag "option", :with=>{:value=>"recent"},:without=>{:selected=>"selected"},:text=>"Most Recent"
          end
        end
        expect(html).to have_tag("div",:with=>{:class=>"editor"}) do
          with_tag "select", :with=>{:id=>"claimed"} do
            with_tag "option", :with=>{:value=>"all",:selected=>"selected"},:text=>"All"
            with_tag "option", :with=>{:value=>"yes"},:without=>{:selected=>"selected"},:text=>"Yes"
            with_tag "option", :with=>{:value=>"no"},:without=>{:selected=>"selected"},:text=>"No"
          end
        end
         expect(html).to have_tag("div",:with=>{:class=>"editor"}) do
          with_tag "select", :with=>{:id=>"cited"} do
            with_tag "option", :with=>{:value=>"all",:selected=>"selected"},:text=>"All"
            with_tag "option", :with=>{:value=>"yes"},:without=>{:selected=>"selected"},:text=>"Yes"
            with_tag "option", :with=>{:value=>"no"},:without=>{:selected=>"selected"},:text=>"No"
          end
        end

        expect(html).to have_tag "form",:with=>{:action=>"/#{Card[:claim].name}",:method=>"GET"}

        expect(html).to include(format.render_company_formgroup.squish)
        expect(html).to include(format.render_topic_formgroup.squish)
        expect(html).to include(format.render_tag_formgroup.squish)


      end
      context "when rendering with parameters" do
        before do
          @company_card = get_a_sample_company
          @topic_card = get_a_sample_topic
          @filter_search_card = Card[:claim].fetch :trait=>:filter_search

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

            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              with_tag("div",:class=>"search-result-list") do
                with_tag("div",:class=>"search-result-item item-content") do
                  with_tag("div",:with=>{:id=>"whateverclaim"})
                end
              end
            end
          end
        end
        context "when condition does not match" do
          it "uses non related tag" do
             Card::Env.params[:tag] = "nonexisitingtag"

            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              without_tag("div",:with=>{:id=>"whateverclaim"})
            end
          end
          it "uses non related company" do
             Card::Env.params[:company] = "Iamnoangel"
            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              without_tag("div",:with=>{:id=>"whateverclaim"})
            end
          end
          it "uses non related topic" do
             Card::Env.params[:topic] = "Iamnodemon"
            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              without_tag("div",:with=>{:id=>"whateverclaim"})
            end
          end
          it "is cited" do
            Card::Env.params[:cited] = "yes"
            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              without_tag("div",:with=>{:id=>"whateverclaim"})
            end
          end
          it "is not cited" do
            Card::Env.params[:cited] = "no"
            new_analysis = Card.create :name=>"#{@new_company.name}+#{@new_topic.name}",:type_id=>Card::WikirateAnalysisID
            new_article = Card.create :name=>"#{@new_company.name}+#{@new_topic.name}+#{Card[:overview].name}",:type_id=>Card::BasicID,:content=>"asdsad#{@claim_card.default_citation}"

            html = Card[:claim].format.render_core
            expect(html).to have_tag("div",:with=>{:id=>"#{Card[:claim].name}+#{Card[:filter_search].cardname.url_key}"}) do
              without_tag("div",:with=>{:id=>"whateverclaim"})
            end
          end
        end
        context "when sorting" do
          before do
            @claim_card1 = create_claim_with_url "whateverclaimrecent","http://www.google.com/yo",{"+company"=>{:content=>"[[#{@new_company.name}]]\r\n[[#{@new_company1.name}]]"},"+topic"=>{:content=>"[[#{@new_topic.name}]]\r\n[[#{@new_topic1.name}]]"},"+tag"=>{:content=>"[[thisisatestingtag]]\r\n[[thisisalsoatestingtag]]"}}
          end
          it "is most recent" do
            Card::Env.params[:sort] = "recent"
            html = Card[:claim].format.render_core
            expect(html.index("whateverclaimrecent")).to be <= html.index("whateverclaim")
          end
          it "is most important" do

            Card::Auth.as_bot do
              vc = @claim_card1.vote_count_card
              vc.vote_up
              vc.save!
            end

            Card::Env.params[:sort] = "important"
            html = Card[:claim].format.render_core
            expect(html.index("whateverclaimrecent")).to be >= html.index("whateverclaim")
          end
        end
      end
    end
  end
end
