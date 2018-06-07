require "rspec"
require_relative "../../support/report_query_shared_examples"

def answer year
  "Joe User+big single+Sony_Corporation+#{year}"
end

RSpec.describe Card::Set::Self::MetricAnswer, "metric answer report queries" do
  describe "created query" do
    include_context "report query", :metric_answer, :created
    variants checked_by_others: answer(2004),
             updated_by_others: [answer(2008), answer(2009)],
             discussed_by_others: answer(2006),
             all: 8
  end

  describe "updated query" do
    include_context "report query", :metric_answer, :updated
    variants all: [answer(2008), answer(2010)]
  end

  describe "discussed query" do
    include_context "report query", :metric_answer, :discussed
    variants all: answer(2007)
  end
end
