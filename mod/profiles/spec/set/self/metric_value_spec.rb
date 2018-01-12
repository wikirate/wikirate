require "rspec"
require_relative "../../support/report_query_shared_examples"

def answer year
  "Joe User+big single+Sony_Corporation+#{year}"
end

RSpec.describe Card::Set::Self::MetricValue, "metric value report queries" do
  describe "created query" do
    include_context "report query", :metric_value, :created
    variants checked_by_others: answer(2004),
             updated_by_others: [answer(2008), answer(2009)],
             discussed_by_others: answer(2006),
             all: 8
  end

  describe "updated query" do
    include_context "report query", :metric_value, :updated
    variants all: [answer(2008), answer(2010)]
  end

  describe "discussed query" do
    include_context "report query", :metric_value, :discussed
    variants all: answer(2007)
  end
end
