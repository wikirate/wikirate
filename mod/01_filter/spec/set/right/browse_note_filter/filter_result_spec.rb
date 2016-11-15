# -*- encoding : utf-8 -*-

require File.expand_path("../../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::BrowseNoteFilter do
  before { login_as "joe_user" }

  let(:div_id) { Card.fetch(:claim, :browse_note_filter).cardname.url_key }
  let(:filter_card) { Card.fetch :claim, :browse_note_filter }
  let(:item_names) { filter_card.item_names }
  describe "filter result" do
    subject { Card[:claim].format(:html).render_core }

    before do
      @company_card = get_a_sample_company
      @topic_card = get_a_sample_topic

      @new_company = Card.create name: "test_company", type_id: Card::WikirateCompanyID
      @new_topic = Card.create name: "test_topic", type_id: Card::WikirateTopicID

      @new_company1 = Card.create name: "test_company1", type_id: Card::WikirateCompanyID
      @new_topic1 = Card.create name: "test_topic1", type_id: Card::WikirateTopicID
      @claim_card = create_claim(
          "whateverclaim",
          "+company" => { content: "[[#{@new_company.name}]]\r\n[[#{@new_company1.name}]]" },
          "+topic" => { content: "[[#{@new_topic.name}]]\r\n[[#{@new_topic1.name}]]" },
          "+tag" => { content: "[[thisisatestingtag]]\r\n[[thisisalsoatestingtag]]" }
      )
    end

    it "filters by company and topic" do
      add_filter :wikirate_topic, [@new_topic.name, @new_topic1.name]
      add_filter :wikirate_company, [@new_company.name, @new_company1.name]
      expect(item_names).to eq ["whateverclaim"]
      is_expected.to have_tag("div", with: { id: div_id }) do
        with_tag("div", class: "search-result-list") do
          with_tag("div", class: "search-result-item item-content") do
            with_tag("div", with: { id: "whateverclaim" })
          end
        end
      end
    end

    context "when condition does not match" do
      it "uses non related company" do
        add_filter :wikirate_company, "Iamnoangel"
        is_expected.to have_tag("div", with: { id: div_id }) do
          without_tag("div", with: { id: "whateverclaim" })
        end
      end
      it "uses non related topic" do
        add_filter :wikirate_topic, "Iamnodemon"
        is_expected.to have_tag("div", with: { id: div_id }) do
          without_tag("div", with: { id: "whateverclaim" })
        end
      end
      it "is cited" do
        add_filter :cited, "yes"
        is_expected.to have_tag("div", with: { id: div_id }) do
          without_tag("div", with: { id: "whateverclaim" })
        end
      end
      it "is not cited" do
        add_filter :cited, "no"
        is_expected.to have_tag("div", with: { id: div_id }) do
          with_tag("div", with: { id: "whateverclaim" })
        end
        Card.create name: "#{@new_company.name}+#{@new_topic.name}",
                    type_id: Card::WikirateAnalysisID
        Card.create name: "#{@new_company.name}+#{@new_topic.name}+#{Card[:overview].name}",
                    type_id: Card::BasicID,
                    content: "sdafdsf #{@claim_card.default_citation}"
        is_expected.to have_tag("div", with: { id: div_id }) do
          without_tag("div", with: { id: "whateverclaim" })
        end
      end
    end

    context "when sorting" do
      def create_claims
        [
            create_claim("claim1"),
            (Timecop.travel(Time.now + 10) { create_claim "important_and_recent" }),
        ]
      end

      def create_voted_claims
        votes = 0
        create_claims.each do |claim_card|
          Card::Auth.as_bot do
            claim_card.vote_count_card.update_attributes! content: votes.to_s
          end
          votes += 10
        end
      end

      it "sorts by most recent" do
        Card::Env.params[:sort] = "recent"
        create_claims
        expect(item_names[0..2]).to eq %w(important_and_recent claim1 whateverclaim)
        expect(subject.index("claim1")).to be < subject.index("whateverclaim")
      end

      it "sorts by most important" do
        Card::Env.params[:sort] = "important"
        create_voted_claims
        expect(item_names[0..2]).to eq %w(important_and_recent whateverclaim claim1)
        expect(subject.index("whateverclaim")).to be < subject.index("claim1")
      end
    end
  end
end
