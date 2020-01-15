RSpec.describe Card::Set::TypePlusRight::WikirateCompany::MetricAnswer do
  let(:company) { Card["Death_Star"] }

  def card_subject
    company.fetch :metric_answer
  end

  check_views_for_errors :core

  describe "#count" do
    it "counts all answers (regardless of year)" do
      expect(card_subject.count).to eq(Answer.where(company_id: company.id).count)
    end
  end

  specify "compact json" do
    expect(format_subject(:json).render(:compact))
      .to include(companies: a_hash, metrics: a_hash, answers: a_hash)
  end

  def a_hash
    an_instance_of ::Hash
  end
end
