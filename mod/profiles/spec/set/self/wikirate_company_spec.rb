require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::WikirateCompany, "company report queries" do
  def answer year, title="big single"
    ["Joe User+#{title}+Sony Corporation+#{year}"]
  end
  describe "created query" do
    include_context "report query", :wikirate_company, :created
    variants all: "created company"
  end

  describe "updated query" do
    include_context "report query", :wikirate_company, :updated
    variants all: "updated company"
  end

  describe "discussed query" do
    include_context "report query", :wikirate_company, :discussed
    variants all: "discussed company"
  end
end
