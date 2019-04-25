format :html do
  view :core, unknown: true do
    voo.items[:view] = :bar
    super() + render_conversation_link
  end

  view :conversation_link, perms: :create do
    link_to "Add Conversation",
            path: { mark: :conversation, action: :new, _Tag: card.name.left },
            class: "btn btn-primary btn-sm mt-2"
  end
end
