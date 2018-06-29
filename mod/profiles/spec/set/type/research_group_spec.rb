
RSpec.describe Card::Set::Type::ResearchGroup do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  let(:research_group) { Card["Jedi"] }

  describe_views :open_content, :bar, :edit,
                 :researcher_tab, :metric_tab, :project_tab do
    it "has no errors" do
      expect(research_group.format.render(view)).to lack_errors
    end
  end

  let(:card_subject) { Card["created research group"] }

  specify "view :bar" do
    expect_view(:bar).to have_tag "div.bar" do
      with_tag "div.bar-left" do
        with_tag "div.thumbnail"
      end
      with_tag "div.bar-middle" do
        with_tag "span.badge"
      end
      with_tag "div.bar-right" do
        with_tag "span.badge"
      end
    end
  end

  specify "view :expanded_bar" do
    expect_view(:expanded_bar).to have_tag "div.expanded-bar" do
      with_tag "div.bar-top" do
        with_tag "div.bar-left" do
          with_tag "div.thumbnail"
        end
        with_tag "div.bar-right" do
          with_tag "span.badge"
        end
      end
      with_tag "div.bar-bottom" do
        with_tag "span.badge"
      end
    end
  end
end
