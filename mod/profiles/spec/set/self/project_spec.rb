require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::Project, "project report queries" do
  describe "created query" do
    include_context "report query", :project, :created
    variants submitted: ["created project", "submitted project"],
             organized: "organized project",
             all: 3
  end

  describe "updated query" do
    include_context "report query", :project, :updated
    variants all: "updated project"
  end

  describe "discussed query" do
    include_context "report query", :project, :discussed
    variants all: ["conversation project", "discussed project"]
  end
end
