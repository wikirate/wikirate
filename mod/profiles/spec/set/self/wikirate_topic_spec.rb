require_relative "../../support/report_query_shared_examples"
require_relative "../../../../../test/seed"

RSpec.describe Card::Set::Self::WikirateTopic, "topic report queries" do
  describe "created query" do
    include_context "report query", :wikirate_topic, :created
    variants all: ["created topic"]
  end

  describe "updated query" do
    include_context "report query", :wikirate_topic, :updated
    variants all: ["updated topic"]
  end

  describe "voted on query" do
    include_context "report query", :wikirate_topic, :voted_on
    variants voted_for: ["voted for topic"],
             voted_against: ["voted against topic"],
             all: 2
  end

  describe "discussed query" do
    include_context "report query", :wikirate_topic, :discussed
    variants all: ["discussed topic"]
  end
end
