RSpec.describe Card::Set::TypePlusRight::WikirateCompany::MetricAnswer do
  let(:company) { Card["Death_Star"] }

  def card_subject
    company.fetch trait: :metric_answer
  end

  check_views_for_errors :core

  describe "#count" do
    it "counts all answers (regardless of year)" do
      expect(card_subject.count).to eq(Answer.where(company_id: company.id).count)
    end
  end
end
