RSpec.describe Card::Set::Self::Dataset do
  check_views_for_errors
  check_views_for_errors format: :csv, views: views(:csv).push(:titled)

  specify "titled_content view" do
    expect_view(:titled_content).to have_tag("div.RIGHT-description")
  end

  specify "featured_boxes view" do
    expect_view(:featured_boxes).to have_tag(".feature-boxes") do
      with_tag ".box", with: { "data-card-name": "Evil Dataset" }
    end
  end

  specify "filtered_content view" do
    expect_view(:filtered_content).to have_tag("div._filtered-content") do
      with_tag "div._filtered-content" do
        with_tag "div.bar-view", with: { "data-card-name": "Evil Dataset" }
      end
    end
  end
end
