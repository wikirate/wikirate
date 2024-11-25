RSpec.describe Card::AnswerQuery::AdvancedFilters do
  include_context "answer query"

  let(:answer_parts) { [-2] } # return company names
  let(:metric_name) { "Jedi+disturbances in the Force" }
  let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }

  describe "#company_answer_query" do
    it "finds companies with metric" do
      expect(search(company_answer: { metric_id: "Joe User+RM".card_id }))
        .to eq(["Death Star"])
    end
  end

  # describe "#answer_query" do
  #   it "finds companies with metric" do
  #     expect(search(answer: { metric_id: "Joe User+RM".card_id }))
  #       .to eq(["Death Star"])
  #   end
  # end

  describe "#related_company_group_query" do
    context "with relation metric" do
      let(:metric_name) { "Commons+Supplied by" }

      it "finds object companies" do
        expect(search(related_company_group: "Googliest"))
          .to eq(["SPECTRE"])
      end
    end

    context "with inverse relation metric" do
      let(:metric_name) { "Commons+Supplier of" }

      it "finds subject companies" do
        expect(search(related_company_group: "Deadliest").sort)
          .to eq(["Google LLC", "Los Pollos Hermanos"])
      end
    end
  end

  describe "#relationship_query" do
    let(:default_filters) { { year: :latest } }

    specify do
      expect(search(relationship: { metric_id: "Commons+Supplier of".card_id,
                                    company_id: "Spectre".card_id }).sort.uniq)
        .to eq(["Google LLC", "Los Pollos Hermanos"])
    end
  end
end
