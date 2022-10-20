RSpec.describe Card::Set::Type::ResearchGroup do
  def card_subject
    "Jedi".card
  end

  check_html_views_for_errors

  specify "view :bar" do
    expect_view(:bar).to have_tag "div.bar" do
      with_tag "div.bar-left" do
        with_tag "div.thumbnail"
      end
      with_tag "div.bar-right" do
        with_tag "span.badge"
      end
    end
  end
end
