# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Claim do
  before do
    login_as "joe_user"
  end

  def create_page iUrl=nil
    url = iUrl || "http://www.google.com/?q=wikirate"
    create_page_with_sourcebox url, {}, "true"
  end

  it "handles too long claim" do
    card = Card.new(type_id: Card::ClaimID, name: "2" * 101)
    expect(card).not_to be_valid
    expect(card.errors).to have_key(:note)
    expect(card.errors[:note].first).to eq("is too long (100 character maximum)")
  end

  it "handles normal claim creation" do
    # create the testing webpage first
    claim_name = "2" * 10

    # test single source
    card = Card.new type_id: Card::ClaimID, name: claim_name,
                    subcards: { "+source" => { content: sample_source.name,
                                               type_id: Card::PointerID } }
    expect(card).to be_valid

    card = Card.new type_id: Card::ClaimID, name: claim_name,
                    subcards: { "+source" => {
                      content: [sourcepage.name, sourcepage.name],
                      type_id: Card::PointerID
                    } }
    expect(card).to be_valid
  end

  it "requires +source card " do
    fake_pagename = "Page-1"
    url = "[[#{fake_pagename}]]"

    # nth here
    card = Card.new(type_id: Card::ClaimID, name: "2" * 100)
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("is empty")
    # without type
    card = Card.new(type_id: Card::ClaimID, name: "2" * 100,
                    subcards: { "+source" => { content: url, type_id: Card::PointerID } })
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("#{fake_pagename} does not exist")

    card = Card.new(type_id: Card::ClaimID, name: "2" * 100,
                    subcards: { "+source" => { content: "[[Home]]", type_id: Card::PointerID } })
    expect(card).not_to be_valid
    expect(card.errors).to have_key :source
    expect(card.errors[:source]).to include("Home is not a valid Source Page")
  end

  describe "views" do
    before do
      login_as "joe_user"
    end

    let(:note) { sample_note }

    it "show help text and note counting for note name when creating claim" do
      html = render_view :name_formgroup, type_id: Card::ClaimID
      expect(html).to include("note-counting")
      expect(html).to include(render_content("note+*type+*add help"))
    end

    it "shows sample_citation view" do
      citation = note.format.render_sample_citation
      expect(citation).to include(%(<div class="sample-citation">))
      expect(citation).to include("#{note.name} {{#{note.name}|cite}}")
    end

    describe "tip view" do
      def tip subcards={}
        claim_card = create_claim @claim_name, subcards
        claim_card.format.render_tip
      end

      context "when the user did not signed in" do
        it "shows nothing" do
          login_as "Anonymous"
          expect(tip).to eq("")
        end
      end
      context "when there is no topic " do
        it "shows tip about adding topic" do
          expect(tip("+company" => "apple"))
            .to include "improve this note by adding a topic."
        end
      end
      context "when there is no company " do
        it "shows tip about adding company" do
          expect(tip("+topic" => "natural resource use"))
            .to include "improve this note by adding a company."
        end
      end
      context "when company and topic exist" do
        context "when  card.analysis_names.size > cited_in.size " do
          it "shows tip about citing this claim in related overview" do
            subcards = { "+company" => "Apple Inc.",
                         "+topic" => "natural resource use" }

            expect(tip(subcards))
              .to include "cite this note in related overviews."
          end
        end
        context "when card.analysis_names.size <= cited_in.size " do
          it "shows nothing" do
            subcards = { "+company" => sample_company.name,
                         "+topic" => sample_topic.name }
            binding.pry
            expect(tip(subcards)).to include("")
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
    topics = sample_topics(2).map(&:name)
    analyses = companies.product(topics).map { |a| a.join "+" }

    claim_card = create_claim "testclaim",
                              "+company" => { content: companies },
                              "+topic" => { content: topics }

    expect(claim_card.analysis_names).to eq(analyses)
  end
end
