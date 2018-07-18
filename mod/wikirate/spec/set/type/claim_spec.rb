# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Claim do
  before do
    login_as "joe_user"
  end

  describe "create" do
    it "doesn't allow name with more than 100 characters" do
      card = Card.new(type_id: Card::ClaimID, name: "2" * 101)
      expect(card).not_to be_valid
      expect(card.errors).to have_key(:note)
      expect(card.errors[:note].first).to eq("is too long (100 character maximum)")
    end

    it "works with single source" do
      claim_name = "2" * 100
      card = Card.new type_id: Card::ClaimID, name: claim_name,
                      subcards: { "+source" => { content: sample_source.name,
                                                 type_id: Card::PointerID } }
      expect(card).to be_valid
    end

    it "works with duplicated source" do
      card = Card.new type_id: Card::ClaimID, name: "test claim",
                      subcards: { "+source" => {
                        content: [sample_source.name, sample_source.name],
                        type_id: Card::PointerID
                      } }
      expect(card).to be_valid
    end

    it "fails without source" do
      card = Card.new(type_id: Card::ClaimID, name: "2" * 100)
      expect(card).not_to be_valid
      expect(card.errors).to have_key :source
      expect(card.errors[:source]).to include("is empty")
    end

    it "fails if source doesn't exist" do
      fake_pagename = "Page-1"
      card = Card.new(type_id: Card::ClaimID, name: "2" * 100,
                      subcards: { "+source" => {
                        content: fake_pagename,
                        type_id: Card::PointerID
                      } })
      expect(card).not_to be_valid
      expect(card.errors).to have_key :source
      expect(card.errors[:source]).to include("#{fake_pagename} does not exist")
    end

    it "fails if given source is not a source" do
      card = Card.new(type_id: Card::ClaimID, name: "2" * 100,
                      subcards: { "+source" => {
                        content: "[[Home]]", type_id: Card::PointerID
                      } })
      expect(card).not_to be_valid
      expect(card.errors).to have_key :source
      expect(card.errors[:source]).to include("Home is not a valid Source Page")
    end
  end

  describe "views" do
    before do
      login_as "joe_user"
    end

    let(:note) { sample_note }

    describe "view :name_formgroup" do
      subject { render_view :name_formgroup, type_id: Card::ClaimID }

      it "has note counting" do
        is_expected.to include(
          "Notes are short (up to 100 characters) statements that summarise some aspect "\
          "of a source, and can be cited within a written overview for a company."
        )
      end
      it "has help text" do
        is_expected.to have_tag "div.note-counting" do
          with_text /100/
        end
      end
    end

    describe "view :sample_citation" do
      subject { note.format.render_sample_citation }

      it "has cite nest" do
        is_expected.to have_tag "div.sample-citation" do
          with_text /#{note.name} {{#{note.name}|cite}}/
        end
      end
    end

    describe "view :tip" do
      let(:cited_claim) { sample_note }

      def claim_tip subcards={}
        claim_card = create_claim "test claim", subcards
        claim_card.format.render_tip
      end

      context "when the user did not sign in" do
        it "shows nothing" do
          login_as "Anonymous"
          expect(claim_tip).to eq("")
        end
      end

      context "when there is no topic" do
        it "shows tip about adding topic" do
          expect(claim_tip("+company" => "apple"))
            .to include "improve this note by adding a topic."
        end
      end

      context "when there is no company " do
        it "shows tip about adding company" do
          expect(claim_tip("+topic" => "natural resource use"))
            .to include "improve this note by adding a company."
        end
      end

      context "when tagged with company and topic" do
        context "but not cited" do
          it "shows tip about citing this claim in related overview" do
            subcards = { "+company" => "Apple Inc.",
                         "+topic" => "natural resource use" }

            expect(claim_tip(subcards))
              .to include "cite this note in related overviews."
          end
        end
        context "and cited in related overview" do
          it "shows nothing" do
            expect(cited_claim.format.render_tip).to eq ""
          end
        end
      end
    end

    it "shows titled view with voting" do
      expect(note.format.render_titled)
        .to have_tag "div.titled_with_voting-view" do
        with_tag "div.vote-up"
        with_tag "div.vote-count"
        with_tag "div.vote-down"
      end
    end

    context "when in open views" do
      it "shows header with voting" do
        expect(note.format.render_open).to have_tag "div.header-vote"
      end
    end

    it "shows the link for view \"missing\"" do
      expect(note.format.render_missing).to eq(note.format.render_link)
    end

    it "show clipboard view" do
      expect(note.format.render_clipboard)
        .to have_tag :i, with: {
          class: "fa fa-clipboard claim-clipboard", id: "copy-button",
          title: "copy claim citation to clipboard",
          "data-clipboard-text" => "#{note.name} {{#{note.name}|cite}}"
        }
    end
  end

  it "returns correct analysis names" do
    companies = sample_companies(2).map(&:name)
    topics =    sample_topics(2).map(&:name)
    analyses =  companies.product(topics).map { |a| a.join "+" }

    claim_card = create_claim "testclaim",
                              "+company" => { content: companies },
                              "+topic" => { content: topics }

    expect(claim_card.analysis_names).to eq(analyses)
  end
end
