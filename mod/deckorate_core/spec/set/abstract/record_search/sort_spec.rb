RSpec.describe Card::Set::Abstract::RecordSearch::Sort do
  describe "#sort_by" do
    it "raises error with invalid parameter" do
      Card::Env.with_params sort_by: "schnookmarkers" do
        expect { format_subject(:base).sort_by }.to raise_error(/Invalid Sort Param/)
      end
    end

    it "does not raise error with valid parameter" do
      Card::Env.with_params sort_by: "metric_bookmarkers" do
        expect { format_subject(:base).sort_by }.not_to raise_error
      end
    end
  end
end
