
describe Card::Set::Type::Program do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  describe_views :open_content, :listing, :edit, :metric_tab, :project_tab do
    it "has no errors" do
      expect_view(view).to lack_errors
    end
  end
end
