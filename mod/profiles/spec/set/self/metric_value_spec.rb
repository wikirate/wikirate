require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::MetricValue, "metric value report queries" do
  describe "created query" do
    include_context "report query", :metric_value, :created
    variants checked_by_others: ["Joe User+big single",
                                 "Jedi+disturbances in the Force+Joe User"],
             updated_by_others: 8,
             discussed_by_others: 9
  end

  describe "updated query" do
    include_context "report query", :metric_value, :updated
    variants all: ["Joe User+small single"]
  end

  describe "voted on query" do
    include_context "report query", :metric_value, :voted_on
    variants voted_for: ["Jedi+disturbances in the Force"],
             voted_against: ["Jedi+deadliness"],
             all: 2
  end
end
