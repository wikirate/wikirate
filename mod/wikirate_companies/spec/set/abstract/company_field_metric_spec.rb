RSpec.describe Card::Set::Abstract::CompanyFieldMetric do
  def card_subject
    %i[core headquarters_location].card
  end

  def google_llc_hq_lookup
    ::Answer.where(
      company_id: "Google LLC".card_id,
      metric_id: card_subject.id
    ).first
  end

  describe "calculate_answers" do
    example do
      card_subject.calculate_answers
      expect(google_llc_hq_lookup.value).to eq("California (United States)")
    end
  end
end
