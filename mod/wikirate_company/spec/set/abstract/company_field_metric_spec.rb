RSpec.describe Card::Set::Abstract::CompanyFieldMetric do
  def card_subject
    Card[:core_headquarters_location]
  end

  def google_llc_hq_lookup
    Answer.where(
      company_id: Card.fetch_id("Google LLC"),
      metric_id: card_subject.id
    ).first
  end

  describe "recalculate_answers" do
    example do
      card_subject.recalculate_answers
      expect(google_llc_hq_lookup.value).to eq("California (United States)")

    end
  end

end