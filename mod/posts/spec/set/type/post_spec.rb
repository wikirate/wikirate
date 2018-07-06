# -*- encoding : utf-8 -*-

describe Card::Set::Type::Post do
  context "with company, topic, and subject" do
    # TODO: move this post to seed data
    def card_subject
      Card.create! type: "Post", na`me: "My Post",
                   subcards: { "+company" => "Death Star",
                               "+topic" => "Force",
                               "+project" => "Evil Project" }
    end

    check_views_for_errors :open_content, :listing, :edit,
                           :wikirate_company_tab, :wikirate_topic_tab, :project_tab
  end
end
