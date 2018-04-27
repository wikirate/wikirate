
RSpec.describe Card::Set::Type::User do
  let(:user) { Card["Joe Camel"] }

  %i[open_content listing edit
     research_group_tab contributions_tab activity_tab].each do |view|
    describe "view: #{view}" do
      it "has no errors" do
        expect(user.format.render(view)).to lack_errors
      end
    end
  end
end
