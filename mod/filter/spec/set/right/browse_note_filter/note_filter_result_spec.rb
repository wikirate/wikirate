# -*- encoding : utf-8 -*-

require File.expand_path("../../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::BrowseNoteFilter do
  before { login_as "joe_user" }

  let(:div_id) { Card.fetch(:claim, :browse_note_filter).name.url_key }
  let(:filter_card) { Card.fetch :claim, :browse_note_filter }
  let(:filtered_item_names) { filter_card.item_names }

  describe "filter result" do
    def expect_filter_result
      is_expected.to have_tag("div", with: { id: div_id }) do
        with_tag("div", class: "search-result-list") do
          with_tag("div", class: "search-result-item item-content") do
            yield
          end
        end
      end
    end

    def expect_filter_result_with id
      expect_filter_result do
        with_tag("div", with: { id: id })
      end
    end

    def expect_filter_result_without id
      expect_filter_result do
        without_tag("div", with: { id: id })
      end
    end

    subject { Card[:claim].format(:html).render_core }

    let(:topics) { sample_topics 2 }
    let(:topic_names) { topics.map(&:name) }
    let(:companies) { sample_companies 2 }
    let(:company_names) { companies.map(&:name) }

    before do
      @claim_card = create_claim(
        "test_note",
        "+company" => company_names.to_pointer_content,
        "+topic" => topic_names.to_pointer_content
      )
    end

    it "passes company and topic filter" do
      add_filter :wikirate_topic, topic_names
      add_filter :wikirate_company, company_names
      expect(filtered_item_names).to eq ["test_note"]
      expect_filter_result_with "test_note"
    end

    it "passes cited filter" do
      add_filter :cited, "no"
      expect_filter_result_with "test_note"
    end

    context "when condition does not match ..." do
      it "... company" do
        add_filter :wikirate_company, "no match"
        expect_filter_result_without "test_note"
      end
      it "... topic" do
        add_filter :wikirate_topic, "no match"
        expect_filter_result_without "test_note"
      end
      # NOTE: temporarily(?) removed "cited" from filter_keys on browse
      # notes page, because of (a) reports that it wasn't working well on
      # tickets, and (b) we're de-emphasizing Reviews/Overviews/Analyses
      #
      # it "... cited" do
      #   add_filter :cited, "yes"
      #   expect_filter_result_without "test_note"
      # end
      # it "... not cited" do
      #   add_filter :cited, "no"
      #   ensure_card "#{company_names.first}+#{topic_names.first}",
      #               type_id: Card::WikirateAnalysisID,
      #               subcards: {
      #                 "+#{Card[:overview].name}" => @claim_card.default_citation
      #               }
      #
      #   expect_filter_result_without "test_note"
      # end
    end

    context "when sorting" do
      def create_claims
        [create_claim("claim1"),
         (Timecop.travel(Time.now + 10) do
           create_claim "important_and_recent"
         end)]
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
        expect(filtered_item_names[0..2])
          .to eq %w[important_and_recent claim1 test_note]
        expect(subject.index("claim1")).to be < subject.index("test_note")
      end

      it "sorts by most important" do
        Card::Env.params[:sort] = "important"
        create_voted_claims
        expect(filtered_item_names[0..2])
          .to eq %w[important_and_recent test_note claim1]

        expect(subject.index("test_note")).to be < subject.index("claim1")
      end
    end
  end
end
