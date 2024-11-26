RSpec.describe Card::Set::Type::Company do
  let(:company_card) { Card["Death Star"] }

  def card_subject
    company_card
  end

  it "shows the link for view \"missing\"" do
    html = render_card :unknown, type_id: Card::CompanyID,
                                 name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::CompanyID,
                                          name: "non-existing-card"))
  end

  specify "view thumbnail_image" do
    expect_view(:thumbnail).to have_tag("div.image-box") do
      with_tag "div.image-box.small" do
        with_tag "a.known-card" do
          with_tag ".wr-icon.wr-icon-company"
        end
      end
    end
  end

  describe "creating company with post request", type: :controller do
    routes { Decko::Engine.routes }
    let(:api_key) { "asdfasf98as8238ruisdsd" }

    before do
      @controller = CardController.new
      Card::Auth.as_bot do
        Card["Joe Admin", :account, :api_key].update! content: api_key
      end
    end

    it "creates company" do
      post :create, params: { card: { name: "new company",
                                      type: "Company",
                                      subcards: { "+:open_corporates_id" => "C0806592",
                                                  "+:headquarters" => "us_ca" } },
                              success: { format: :json },
                              confirmed: true,
                              api_key: api_key }
      expect_card("new company")
        .to exist
        .and have_a_field(:open_corporates_id).with_content("C0806592")
        .and have_a_field(:headquarters).with_content("California (United States)")
    end
  end

  describe "renaming company" do
    def rename_company!
      company_card.update! name: "Life Star"
    end

    it "refreshes all answers" do
      rename_company!
      expect(::Answer.where(company_id: "Death Star".card_id).count).to eq(0)
    end
  end

  describe "deleting company" do
    it "deletes all answers", as_bot: true do
      company_id = company_card.id
      company_card.delete!
      expect(::Answer.where(company_id: company_id).count).to eq(0)
      expect(Relationship.where(subject_company_id: company_id).count).to eq(0)
      expect(Relationship.where(object_company_id: company_id).count).to eq(0)
    end
  end

  describe "#inapplicable_metric_ids" do
    let(:metric) { Card["Jedi+cost of planets destroyed"] }

    before do
      Card::Auth.as_bot do
        metric.company_group_card.update! content: "Deadliest"
        # restricts metric to Death Star, Los Pollos Hermanos, and SPECTRE
      end
    end

    it "finds metrics that exclude it" do
      expect(Card["Samsung"].inapplicable_metric_ids).to eq([metric.id])
    end

    it "does not finds metrics that include it" do
      expect(Card["Death Star"].inapplicable_metric_ids).to eq([])
    end
  end

  # These tests were passing but breaking other tests somehow on semaphore.
  # Cannot replicate locally, but you can see the issue by running just these tests
  # on semaphore and uncommenting the `puts` in
  # mod/wikirate_companies/spec/support/spec_helper.rb
  describe "fulltext_match: value" do
    def expect_query query
      expect Card::Query.run(query.reverse_merge(return: :name, sort_by: :name))
    end

    it "matches on search_content" do
      expect_query(fulltext_match: "Alphabet", type: "Company").to eq(["Google LLC"])
    end

    it "doesn't allow word fragments" do
      expect_query(fulltext_match: "gle i", type: "Company")
        .to eq([])
    end

    it "switches to sql regexp if preceeded by a ~" do
      expect_query(fulltext_match: "~ gle i", type: "Company").to eq(["Google Inc."])
    end
  end
end
