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

  def tab_count_title count_card_tag
    two_line_tab count_card_tag.cardname.vary(:plural),
                 card.fetch(trait: count_card_tag).cached_count
  end
end
