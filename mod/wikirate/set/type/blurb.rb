format :html do
  BUTTON_TEXT = {
    homepage_action1: "Sign up"
  }
  LINK_TEXT = {
    homepage_action2: "Come meet us",
    homepage_action4: "Get in touch",
    community_action1: "Join the conversation",
    community_action2: "Become a steward",
    community_action3: "Subscribe for updates",
    community_action4: "Join the Slack community",
    community_action5: "Get in touch",
    community_action6: "Subscribe",
  }

  view :action_card, template: :haml
  view :cta, template: :haml
  view :cta_section, template: :haml

  def button_or_link
    if (text = BUTTON_TEXT[card.codename])
      action_link text, "btn btn-outline-primary"
    else
      action_link LINK_TEXT[card.codename] || "Learn more", "pb-1"
    end
  end

  private

  def action_link text, klass=nil
    link_to "#{text} <span class='ms-2'>#{icon_tag :forward}</span>",
            href: card.uri,
            class: "d-flex #{klass}"
  end
end