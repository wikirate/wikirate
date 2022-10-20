RSpec.describe Card::Set::Type::MetricAnswer do
  describe "answers by value type" do
    def card_subject
      sample_answer value_type
    end

    Wikirate::Samples::METRIC_NAMES.each_key do |value_type|
      context "with #{value_type} answer" do
        let(:value_type) { value_type }

        check_views_for_errors
        check_views_for_errors views: %i[bar page concise]
      end
    end
  end

  describe "answers by metric type" do
    def card_subject
      subject_with_metric_type
    end

    {
      score: "Jedi+disturbances in the Force+Joe User+Death Star+1977",
      wikirating: "Jedi+deadliness+Death_Star+1977",
      formula: "Jedi+friendliness+Death Star+1977",
      relationship: "Jedi+more evil+Death Star+1977"
    }.each do |metric_type, answer_name|
      context "with #{metric_type} answer" do
        let(:subject_with_metric_type) { Card.fetch answer_name }

        check_views_for_errors
        check_views_for_errors views: [:page]
      end
    end
  end
end
