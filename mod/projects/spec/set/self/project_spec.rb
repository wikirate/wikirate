describe Card::Set::Self::Project do
  specify "view core" do
    expect_view(:core).to have_tag("div.card-slot") do
      with_tag "div.tabbable"
      with_tag "div.tab-content"
    end
  end
end
