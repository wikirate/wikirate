
RSpec.describe Card::Set::Type::ResearchGroup do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  let(:research_group) { Card["Jedi"] }

  describe_views :open_content, :listing, :edit,
                 :researcher_tab, :metric_tab, :project_tab do |view|
    it "has no errors" do
      expect(research_group.format.render(view)).to lack_errors
    end
  end
end
