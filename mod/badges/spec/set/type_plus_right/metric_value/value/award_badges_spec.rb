# -*- encoding : utf-8 -*-

require_relative "../../../../support/award_answer_create_badges_shared_examples"
require_relative "../../../../support/award_answer_badges_shared_examples"

RSpec.describe Card::Set::TypePlusRight::MetricValue::Value::AwardBadges do
  let(:sample_acting_card) { sample_metric_value.value_card }

  describe "create badges" do
    let(:start_year) { 1990 }
    let(:metric_card) { Card["Joe User+researched number 2"] }

    def execute_awarded_action count
      year = start_year + count
      metric_card.create_values true do
        Death_Star year => count
      end
    end

    context "reached bronze create threshold" do
      it_behaves_like "create badges", 1, "Researcher"
    end

    context "reached silver create threshold" do
      it_behaves_like "create badges", 2, "Research Pro"
    end

    context "reached gold create threshold" do
      it_behaves_like "create badges", 3, "Research Master"
    end
  end

  describe "update badges" do
    let(:badge_action) { :update }

    def execute_awarded_action count
      answer_card(count).value_card.update_attributes! content: count
    end

    context "reached bronze update threshold" do
      it_behaves_like "answer badges", 1, "Answer Chancer"
    end

    context "reached silver create threshold" do
      it_behaves_like "answer badges", 2, "Answer Enhancer"
    end

    context "reached gold create threshold" do
      it_behaves_like "answer badges", 3, "Answer Advancer"
    end
  end
end
