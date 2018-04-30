
RSpec.describe Card::Set::Type::ResearchGroup do
  let(:research_group) { Card["Jedi"] }

  %i[open_content listing edit
     researcher_tab metric_tab project_tab].each do |view|
    describe "view: #{view}" do
      it "has no errors" do
        expect(research_group.format.render(view)).to lack_errors
      end
    end
  end
end
