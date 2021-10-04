# -*- encoding : utf-8 -*-

require_relative "../../../spec/support/formula.rb"

RSpec.describe Card::Set::MetricType::Formula, "translation formula" do
  include_context "formula"
  #
  before do
    @metric_name = "Joe User+RM"
    @metric_name1 = "Joe User+researched number 1"
    @metric_name2 = "Joe User+researched number 2"
    @metric_name3 = "Joe User+researched number 3"
  end

  def build_formula formula
    format formula, @metric_name1, @metric_name2, @metric_name3
  end
end
