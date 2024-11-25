RSpec.describe Card::Set::TypePlusRight::Answer::Source do
  let(:source) { sample_source }
  let(:source_card) { new_answer.source_card }
  let(:metric) { sample_metric }
  let(:company) { sample_company }

  def new_answer args={}
    args.reverse_merge! value: "1234", year: "2015", source: source.name
    create_answer args
  end

  describe "answer creation" do
    it "includes source in +source" do
      expect(source_card.item_names).to include(source.name)
    end

    it "updates source's company" do
      new_answer
      source_company = source.fetch :company
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
        .to be_invalid.because_of("+Source": include("No such source exists"))
    end

    it "fails if source card cannot be created" do
      expect(build_answer(source: nil))
        .to be_invalid.because_of(source: include("required"))
    end

    context "when source is url" do
      let(:url) { "https://xkcd.com/1735/" }

      it "adds source when explicitly triggered to do so" do
        a = new_answer source: { content: url, trigger_in_action: :auto_add_source },
                       user: "Joe Admin"
        # shouldn't have to be Joe Admin.
        # It avoids permissions issue having to do with User+Source+Badges Earned
        # Goes away if we get rid of unwanted structure rule
        # that makes User+Source an HTML card
        expect(a.source_card.first_name)
          .to eq(Card::Source.search_by_url(url).first.name)
      end

      it "fails when not triggered to auto-add" do
        expect(build_answer(source: url))
          .to be_invalid.because_of("+Source": include("requires event configuration"))
      end
    end
  end
end
