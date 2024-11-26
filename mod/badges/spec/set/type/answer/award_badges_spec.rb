# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Answer do
  let(:sample_acting_card) { sample_answer }

  describe "create badges" do
    let(:start_year) { 1990 }
    let(:metric) { "Joe User+researched number 2" }

    def execute_awarded_action count
      year = start_year + count
      create_answers metric, true do
        Death_Star year => count
      end
    end

    context "when reached bronze create threshold" do
      it_behaves_like "create badges", 1, "Researcher"
    end

    context "when reached silver create threshold" do
      it_behaves_like "create badges", 2, "Research Pro"
    end

    context "when reached gold create threshold" do
      it_behaves_like "create badges", 3, "Research Master"
    end
  end

  describe "update badges" do
    let(:badge_action) { :update }

    def execute_awarded_action count
      answer_card(count).value_card.update! content: count
    end

    context "when reached bronze update threshold" do
      it_behaves_like "answer badges", 1, "Answer Chancer"
    end

    context "when reached silver create threshold" do
      it_behaves_like "answer badges", 2, "Answer Enhancer"
    end

    context "when reached gold create threshold" do
      it_behaves_like "answer badges", 3, "Answer Advancer"
    end
  end
end
