RSpec.describe Card::Set::Self::ResearchGroup do

  check_html_views_for_errors
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
