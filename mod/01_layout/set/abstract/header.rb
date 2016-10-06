format :html do
  view :rich_header do |args|
    output [_render_image(args), _render_title(args)]
  end

  def tab_count_title title, count_card_tag
    count_card = card.fetch trait: [count_card_tag, :cached_count]
    count = subformat(count_card)._render_core
    <<-HTML
      <span class="count-number clearfix">#{count}</span>
      <span class="count-label">#{title}</span>
    HTML
  end
end
