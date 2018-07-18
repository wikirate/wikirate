require_relative "award_badges_shared_examples"

shared_context "answer badges" do |threshold, badge_name|
  let(:badge_type) { :metric_answer }
  let(:start_year) { 2003 }
  let(:metric_card) { Card["Joe User+big single"] }

  include_context "award badges context", threshold
  include_context "award badges", threshold, badge_name

  def trigger_awarded_action count=0
    with_user "John" do
      count.times do |i|
        execute_awarded_action i + 1
      end
    end
  end

  def answer_card number
    year = start_year + number - 1
    Card["#{metric_card.name}+Sony Corporation+#{year}"]
  end
end
