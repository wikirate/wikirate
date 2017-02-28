require_relative "../../support/report_query_shared_examples"

RSpec.describe Card::Set::Self::MetricValue, "metric value report queries" do
  def answer year, title="big single"
    ["Joe User+#{title}+Sony Corporation+#{year}"]
  end
  describe "created query" do
    include_context "report query", :metric_value, :created
    variants checked_by_others: answer(2008),
             updated_by_others: answer(2009),
             discussed_by_others: answer(2006),
             all: 5
  end

  describe "updated query" do
    include_context "report query", :metric_value, :updated
    variants all: answer(2010),
             checked: answer(2005)
  end

  describe "discussed query" do
    include_context "report query", :metric_value, :discussed
    variants all: answer(2010, "small single")
  end
end