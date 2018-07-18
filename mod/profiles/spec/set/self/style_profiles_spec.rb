# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::StyleProfiles do
  it "loads scss file" do
    expect(Card[:style_profiles].content)
      .to include ".RIGHT-activity.titled-view .activity"
  end
end
