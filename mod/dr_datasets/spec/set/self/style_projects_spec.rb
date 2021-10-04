# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::StyleProjects do
  it "loads scss file" do
    expect(Card[:style_projects].content).to include ".project-details-info .lead"
  end
end
