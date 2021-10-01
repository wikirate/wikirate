RSpec.describe Card::Set::TypePlusRight::WikirateCompany::MetricAnswer do
  it_behaves_like "cached count", "Death Star+answer", 32, 2 do
    # increment = 2, because one researched answer + one calculated answer
    let :add_one do
      Card["Jedi+disturbances in the force"].create_answers true do
        Death_Star "1999" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end

  let(:company) { Card["Death_Star"] }

  def card_subject
    company.fetch :metric_answer
  end

  check_html_views_for_errors

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

  describe "csv export" do
    it "filters" do
      Card::Env.with_params filter: { metric_name: "dark" } do
        csv = format_subject(:csv).render_core
        expect(csv).to include("darkness").and not_include("deadliness")
      end
    end
  end
end
