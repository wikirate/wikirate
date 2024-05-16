RSpec.describe Card::AnswerQuery::CompanyFilters do
  include_context "answer query"

  specify "#company_category_query" do
    expect(search(company_category: "A").sort)
      .to eq ["Death Star+2001", "SPECTRE+2000"]
  end

  context "with fixed metric" do
    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    describe "#filter_by_company_name" do
      it "finds exact match" do
        expect(search(company_name: "Death")).to eq ["Death Star+2001"]
      end

      it "finds partial match" do
        expect(search(company_name: "at").sort)
          .to eq ["Death Star+2001", "Slate Rock and Gravel Company+2006"]
      end

      it "ignores case" do
        expect(search(company_name: "death")).to eq ["Death Star+2001"]
      end
    end

    describe
  end
end
