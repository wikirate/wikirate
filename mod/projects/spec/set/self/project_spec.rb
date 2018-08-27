describe Card::Set::Self::Project do
  specify "view core" do
    expect_view(:core).to have_tag("div.card-slot") do
      have_tag "div.tabbable"
      have_tag "div.tab-content"
    end
  end
end
