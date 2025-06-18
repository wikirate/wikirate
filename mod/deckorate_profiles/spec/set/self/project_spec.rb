RSpec.describe Card::Set::Self::Project, "project report queries" do
  describe "created query" do
    include_context "report query", :project, :created
    variants submitted: "created project",
             all: 1
  end

  describe "updated query" do
    include_context "report query", :project, :updated
    variants all: "updated project"
  end

  describe "discussed query" do
    include_context "report query", :project, :discussed
    variants all: ["discussed project"]
  end
end
