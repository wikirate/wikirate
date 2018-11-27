format :html do
  view :cite_bar, template: :haml

  view :preview_bar, template: :haml

  view :close_icon, template: :haml

  view :wikirate_copy_message, template: :haml

  view :bar_and_preview, cache: :never do
    wrap { [
            render_close_icon,
            render_mini_bar,
            render_wikirate_copy_message,
            render_preview
        ] }
  end

  view :cite_button, template: :haml

  view :uncite_button, template: :haml

  def hidden_item_input
    tag :input, type: "hidden", class: "_pointer-item", value: card.name
  end
end
