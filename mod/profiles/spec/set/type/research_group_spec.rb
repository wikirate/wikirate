RSpec.describe Card::Set::Type::ResearchGroup do
  def card_subject
    Card["Jedi"]
  end

  check_html_views_for_errors

  specify "view :info_bar" do
    expect_view(:info_bar).to have_tag "div.bar" do
      with_tag "div.bar-left" do
        with_tag "div.thumbnail"
      end
      with_tag "div.bar-middle" do
        with_tag "div.RIGHT-topic"
      end
      with_tag "div.bar-right" do
        with_tag "span.badge"
      end
    end
  end

  specify "view :expanded_bar" do
    expect_view(:expanded_bar).to have_tag "div.expanded-bar" do
      with_tag "div.bar" do
        with_tag "div.bar-left" do
          with_tag "div.thumbnail"
        end
        with_tag "div.bar-right" do
          with_tag "span.badge"
        end
      end
      with_tag "div.bar-bottom" do
        with_tag "div.RIGHT-topic"
      end
    end
  end
end
