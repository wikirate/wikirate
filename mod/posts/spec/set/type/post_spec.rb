# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Post do
  context "with body" do
    # TODO: move this post to seed data
    def card_subject
      Card.create! type: "Post", name: "My Post",
                   subcards: { "+body" => "body text" }
    end

    # let(:card_subject) { post }

    check_html_views_for_errors

    specify "view bar" do
      expect_view(:bar).to have_tag "div.bar" do
        with_tag "div.bar-left", "My Post"
        without_tag "div.bar-middle"
      end
    end

    specify "expanded bar" do
      expect_view(:expanded_bar).to have_tag ".expanded-bar" do
        with_tag ".bar" do
          with_tag ".bar-left", "My Post"
          without_tag "div.bar-middle"
        end
        with_tag "div.bar-bottom", /body text/
      end
    end
  end
end
