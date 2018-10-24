# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Post do
  context "with company, topic, and subject" do
    # TODO: move this post to seed data
    def card_subject
      Card.create! type: "Post", name: "My Post",
                   subcards: { "+company" => "Death Star",
                               "+topic" => "Force",
                               "+project" => "Evil Project",
                               "+body" => "body text" }
    end

    # let(:card_subject) { post }

    check_views_for_errors :open_content, :bar, :edit,
                           :wikirate_company_tab, :wikirate_topic_tab, :project_tab

    let(:badges_matcher) {  %w[1 Companies 1 Topics 1 Projects].join('\s*') }

    specify "view bar" do
      expect_view(:bar).to have_tag "div.bar" do
        with_tag "div.bar-left", "My Post"
        with_tag "div.bar-middle"
        with_tag "div.bar-right", /#{badges_matcher}/
      end
    end

    specify "expanded bar" do
      expect_view(:expanded_bar).to have_tag ".expanded-bar" do
        with_tag ".bar-top" do
          with_tag ".bar-left", "My Post"
          without_tag "div.bar-middle"
          with_tag "div.bar-right", /#{badges_matcher}/
        end
        with_tag "div.bar-bottom", /body text/
      end
    end
  end
end
