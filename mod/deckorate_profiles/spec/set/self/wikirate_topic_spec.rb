RSpec.describe Card::Set::Self::WikirateTopic, "topic report queries" do
  describe "created query" do
    include_context "report query", :wikirate_topic, :created
    variants all: ["created topic"]
  end

  describe "updated query" do
    include_context "report query", :wikirate_topic, :updated
    variants all: ["updated topic"]
  end

  describe "bookmarked query" do
    include_context "report query", :wikirate_topic, :bookmarked
    variants all: ["bookmarked topic"]
  end

  describe "discussed query" do
    include_context "report query", :wikirate_topic, :discussed
    variants all: ["discussed topic"]
  end
end
