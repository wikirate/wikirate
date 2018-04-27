require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::ResearchGroup do
  describe "created query" do
    include_context "report query", :research_group, :created
    variants all: "created research group"
  end

  describe "updated query" do
    include_context "report query", :research_group, :updated
    variants all: "updated research group"
  end

  describe "discussed query" do
    include_context "report query", :research_group, :discussed
    variants all: "discussed research group"
  end
end
