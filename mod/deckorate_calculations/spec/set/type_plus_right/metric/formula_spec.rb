# encoding: UTF-8

RSpec.describe Card::Set::TypePlusRight::Metric::Formula do
  it "show input options in thumbnail" do
    expect_view(:core, card: "Jedi+deadliness average+formula")
      .to have_tag "div.thumbnail", with: { "data-card-name": "Jedi+deadliness" } do

      with_tag "div.thumbnail-subtitle", /Research.*year: -2..0/m
    end
  end
end
