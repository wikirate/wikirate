format :html do
  view :solocomplete do
    solocomplete_input
  end

  def solocomplete_input
    items = card.item_names(context: :raw)
    items = [""] if items.empty?
    input = text_field_tag "pointer_item",
                           items[0],
                           class: "pointer-item-text form-control",
                           "data-options-card": card.options_card_name

    %(
      <ul class="pointer-list-editor pointer-list-ul">
        <li class="pointer-li"><span class="input-group">#{input}</span></li>
      </ul>
    ).html_safe
  end
end
