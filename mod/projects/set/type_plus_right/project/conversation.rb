format :html do
  view :project_conversation, tags: :unknown_ok do
    @content_body = true
    voo.items[:view] = :content
    voo.items[:structure] = "list item"
    wrap_with :div, class: "titled-view project-conversation" do
      [
        _render_header,
        wrap_body { _render_core },
        conversation_link
      ]
    end
  end

  def conversation_link
    link_to "Add Conversation",
            path: { mark: :conversation, action: :new,
                    _Project: card.cardname.left },
            class: "btn btn-primary"
  end
end
