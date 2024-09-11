RSpec.describe Card::Set::Self::Topic do
  describe "created query" do
    include_context "report query", :topic, :created
    variants all: ["created topic"]
  end

  describe "updated query" do
    include_context "report query", :topic, :updated
    variants all: ["updated topic"]
  end

  describe "bookmarked query" do
    include_context "report query", :topic, :bookmarked
    variants all: ["bookmarked topic"]
  end

  describe "discussed query" do
    include_context "report query", :topic, :discussed
    variants all: ["discussed topic"]
  end
end
