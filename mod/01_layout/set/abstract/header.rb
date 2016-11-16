format :html do
  view :rich_header do |args|
    output [_render_image(args), _render_title(args)]
  end

  def tab_count_title title, count_card_tag
    count_card = card.fetch trait: [count_card_tag, :cached_count]
    count = subformat(count_card)._render_core
    wrap_with :div do
      [
        content_tag(:span, title, class: "count-label"),
        content_tag(:span, count, class: "count-number badge clearfix")
      ]
    end
  end
end
