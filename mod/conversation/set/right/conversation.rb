format :html do
  view :core, tags: :unknown_ok do
    voo.items[:view] = :listing
    super() + render_conversation_link
  end

  view :conversation_link, perms: :create do
    link_to "Add Conversation",
            path: { mark: :conversation, action: :new, _Tag: card.name.left },
            class: "btn btn-primary"
  end
end

