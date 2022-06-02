RSpec.describe Card::Set::Type::WikirateCompany do
  subject do
    Card::Query.run @query.reverse_merge(return: :name, sort_by: :name)
  end

  # These tests were passing but breaking other tests somehow on semaphore.
  # Cannot replicate locally, but you can see the issue by running just these tests
  # on semaphore and uncommenting the `puts` in
  # mod/deckorate_search/spec/support/spec_helper.rb
  xdescribe "fulltext_match: value" do
    it "matches on search_content" do
      @query = { fulltext_match: "Alphabet", type: "Company" }
      is_expected.to eq(["Google LLC"])
    end

    it "doesn't allow word fragments" do
      @query = { fulltext_match: "gle i", type: "Company" }
      is_expected.to eq([])
    end

    it "switches to sql regexp if preceeded by a ~" do
      @query = { fulltext_match: "~ gle i", type: "Company" }
      is_expected.to eq(["Google Inc."])
    end
  end
end
