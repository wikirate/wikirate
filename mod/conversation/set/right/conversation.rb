format :html do
  view :core, tags: :unknown_ok do
    voo.items[:view] = :content
    voo.items[:structure] = "list item"
    binding.pry
    super + conversation_link
  end

  def conversation_link
    link_to "Add Conversation",
            path: { mark: :conversation, action: :new,
                    _Tag: card.name.left },
            class: "btn btn-primary"
  end
end

