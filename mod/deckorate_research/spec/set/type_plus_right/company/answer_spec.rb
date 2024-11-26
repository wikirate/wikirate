RSpec.describe Card::Set::TypePlusRight::Company::Answer do
  it_behaves_like "cached count", ["Death Star", :answer], 35, 3 do
    # increment = 2, because one researched answer + one calculated answer
    let :add_one do
      create_answers "Jedi+disturbances in the force", true do
        Death_Star "1999" => "yes"
      end
    end
    let :delete_one do
      Card["Jedi+disturbances in the force+Death Star+1990"].delete
    end
  end

  let(:company) { Card["Death_Star"] }

  def card_subject
    company.fetch :answer
  end

  check_views_for_errors

  describe "#count" do
    it "counts all answesr (regardless of year)" do
      expect(card_subject.count).to eq(::Answer.where(company_id: company.id).count)
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
      Card::Env.with_params filter: { metric_keyword: "dark" } do
        csv_array = format_subject(:csv).render_body.first
        expect(csv_array)
          .to include("Jedi+darkness rating").and not_include("Jedi+deadliness")
      end
    end
  end
end
