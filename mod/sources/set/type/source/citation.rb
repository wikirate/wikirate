format :html do
  view :cite_bar, template: :haml

  view :preview_bar, template: :haml

  view :bar_and_preview, cache: :never do
    wrap { [render_mini_bar, render_preview] }
  end

  view :cite_button, template: :haml

  view :uncite_button, template: :haml

  def hidden_item_input
    tag :input, type: "hidden", class: "_pointer-item", value: card.name
  end
end
