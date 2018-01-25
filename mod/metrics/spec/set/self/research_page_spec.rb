describe Card::Set::Self::ResearchPage do
  describe "#slot_machine" do
    subject do
      Card[:research_page].format
                          .slot_machine metric: "Joe User+researched",
                                        company: "Death Star",
                                        year: "2014"
    end

    it "has metric slot" do
      is_expected.to have_tag ".metric" do
        with_tag ".metric-color", /researched/
      end
    end

    it "has company slot" do
      is_expected.to have_tag ".company" do
        with_tag ".company-color", /Death Star/
      end
    end

    it "has year slot" do
      is_expected.to have_tag ".year" do
        with_tag :strong, /2014/
      end
    end

    it "has answer slot" do
      is_expected.to have_tag :div, /Answer/
    end
  end
end
