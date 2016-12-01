format :html do
  view :rich_header do
    output [_render_image, _render_title]
  end

  def two_line_tab label, info="&nbsp;"
    wrap_with :div, class: "text-center" do
      [
          wrap_with(:span, info, class: "count-number clearfix"),
          wrap_with(:span, label, class: "count-label")
      ]
    end
  end

  def tab_count_title label, count_card_tag
    search_card = card.fetch trait: count_card_tag
    count = subformat(search_card.cached_count_card)._render_core
    count = "0" unless count.present?
    two_line_tab label, count
  end
end
