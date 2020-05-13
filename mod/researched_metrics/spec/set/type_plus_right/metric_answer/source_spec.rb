RSpec.describe Card::Set::TypePlusRight::MetricAnswer::Source do
  let(:source) { sample_source }
  let(:source_card) { new_answer.source_card }
  let(:metric) { sample_metric }
  let(:company) { sample_company }
  let :new_answer do
    create_answer value: "1234", year: "2015", source: source.name
  end

  describe "answer creation" do
    it "includes source in +source" do
      expect(source_card.item_names).to include(source.name)
    end

    it "updates source's company" do
      new_answer
      source_company = source.fetch :wikirate_company
      expect(source_company.item_cards).to include(company)
    end

    it "updates source's report type" do
      new_answer
      source_report_type = source.fetch :report_type
      expect(source_report_type.item_names)
        .to include("Conflict Mineral Report")
    end

    it "fails with a non-existing source" do
      expect(build_answer(source: "Page-1"))
        .to be_invalid.because_of("+source": include("No such source exists"))
    end

    it "fails if source card cannot be created" do
      expect(build_answer(source: nil))
        .to be_invalid.because_of(source: include("required"))
    end

    context "when triggering auto-create sources" do

    end
  end
end
