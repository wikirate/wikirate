require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::Metric, "metric report queries" do
  describe "created query" do
    include_context "report query", :metric, :created
    variants submitted: ["Jedi+disturbances in the Force+Joe User",
                         "Joe User+big single"],
             designed: 11,
             all: 12
  end

  describe "updated query" do
    include_context "report query", :metric, :updated
    variants all: ["Joe User+small single"]
  end

  describe "bookmark query" do
    include_context "report query", :metric, :bookmarked
    variants all: ["Jedi+disturbances in the Force"]
  end

  describe "discussed query" do
    include_context "report query", :metric, :discussed
    variants all: ["Jedi+Victims by Employees"]
  end
end
