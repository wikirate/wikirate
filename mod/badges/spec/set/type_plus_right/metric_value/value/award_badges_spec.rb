# -*- encoding : utf-8 -*-

require_relative "../../../../support/answer_create_shared_examples"

describe Card::Set::TypePlusRight::MetricValue::Value::AwardBadges do
  START_YEAR = 1990
  METRIC_NAME = "Joe User+researched number 2"
  let(:metric_card) { Card[METRIC_NAME] }
  let(:badge_type) { :metric_value }

  context "reached bronze create threshold" do
    it_behaves_like "create badges", 1, "Researcher"
  end

  context "reached silver create threshold" do
    it_behaves_like "create badges", 2, "Research Engine"
  end

  context "reached gold create threshold" do
    it_behaves_like "create badges", 3, "Research Fellow"
  end
end
