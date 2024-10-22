format :html do
  BUTTON_TEXT = {
    homepage_action1: "Sign up"
  }.freeze
  LINK_TEXT = {
    homepage_action2: "Come meet us",
    homepage_action4: "Get in touch",
    # community_action1: "Join the conversation",
    community_action2: "Get in touch",
    # community_action3: "Subscribe for updates",
    community_action4: "Join the Slack community",
    community_action5: "Get in touch",
    community_action6: "Subscribe"
  }.freeze

  view :action_card, template: :haml, cache: :yes
  view :cta, template: :haml, cache: :yes
  view :cta_section, template: :haml, cache: :yes

  def button_or_link
    if (text = BUTTON_TEXT[card.codename])
      action_link text, "btn btn-outline-primary"
    else
      text = LINK_TEXT[card.codename]
      action_link "#{text} #{material_symbol_tag :east}" || "Learn more", "pb-1"
    end
  end

  private

  def action_link text, klass=nil
    link_to text,
            href: card.uri,
            target: (card.uri.match?(/^http/) ? "_external" : ""),
            class: "action-link d-flex #{klass}"
  end
end
