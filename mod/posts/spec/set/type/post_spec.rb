# -*- encoding : utf-8 -*-

describe Card::Set::Type::Post do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  context "with company, topic, and subject" do
    # TODO: move this post to seed data
    let(:post) do
      Card.create! type: "Post", name: "My Post",
                   subcards: { "+company" => "Death Star",
                               "+topic" => "Force",
                               "+project" => "Evil Project" }
    end

    describe_views :open_content, :listing, :edit,
                   :wikirate_company_tab, :wikirate_topic_tab, :project_tab do
      it "has no errors" do
        expect(post.format.render(view)).to lack_errors
      end
    end
  end
end
