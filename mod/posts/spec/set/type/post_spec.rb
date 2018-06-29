# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Post do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  context "with company, topic, and subject" do
    # TODO: move this post to seed data
    let(:post) do
      Card.create! type: "Post", name: "My Post",
                   subcards: { "+company" => "Death Star",
                               "+topic" => "Force",
                               "+project" => "Evil Project",
                               "+body"  => "body text" }
    end

    let(:card_subject) { post }

    describe_views :open_content, :bar, :edit,
                   :wikirate_company_tab, :wikirate_topic_tab, :project_tab do
      it "has no errors" do
        expect(post.format.render(view)).to lack_errors
      end
    end

    specify "view bar" do
      badges_matcher = %w[1 Company 1 Topic 1 Project].join('\s*')

      expect_view(:bar).to have_tag "div.bar" do
        with_tag "div.bar-left", "My Post"
        without_tag "div.bar-middle"
        with_tag "div.bar-right", /#{badges_matcher}/
      end
    end

    specify "expanded bar" do
      expect_view(:expanded_bar).to have_tag "expanded-bar" do
        with_tag "bar-top" do
          with_tag "bar-left", "My Post"
          without_tag "div.bar-middle"
          with_tag "div.bar-right", /#{badges_matcher}/
        end
        with_tag "div.bar-bottom", "body text"
      end
    end
  end
end
