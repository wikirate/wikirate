RSpec.describe Card::AnswerQuery::CompanyFilters do
  include_context "answer query"

  context "with fixed metric" do
    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    describe "#filter_by_company_keyword" do
      it "finds exact match" do
        expect(search(company_keyword: "Death Star")).to eq ["Death Star+2001"]
      end

      it "finds partial match" do
        expect(search(company_keyword: "at").sort)
          .to eq ["Death Star+2001", "Slate Rock and Gravel Company+2006"]
      end

      it "ignores case" do
        expect(search(company_keyword: "death")).to eq ["Death Star+2001"]
      end
    end

    specify "#filter_by_company_category" do
      expect(search(company_category: "A").sort)
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end

    describe "#filter_by_company_identifier" do
      let(:answer_parts) { [-2] }

      it "filters by type" do
        expect(search(company_identifier: { type: "Wikipedia" }))
          .to eq(["Death Star", "SPECTRE"])
      end

      it "filters by matching value" do
        expect(search(company_identifier: { value: "death" }))
          .to eq(["Death Star"])
      end
    end
  end
end
