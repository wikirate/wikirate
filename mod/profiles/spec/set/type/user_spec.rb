
RSpec.describe Card::Set::Type::User do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  let(:user) { Card["Joe Camel"] }

  describe_views :open_content, :edit,
                 :research_group_tab, :contributions_tab, :activity_tab do
    it "has no errors" do
      expect(user.format.render(view)).to lack_errors
    end
  end
end
