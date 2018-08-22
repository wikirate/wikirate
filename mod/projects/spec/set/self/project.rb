describe Card::Set::Self::Project do
  specify "view core" do
    expect_view(:core).to have_tag("div.card") do
      with_tag "div.card-header"
      with_tag "div.card-body"
    end
  end
end
