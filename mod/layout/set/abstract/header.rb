format :html do
  view :rich_header do
    [_render_image, _render_title]
  end

  def two_line_tab label, info="&nbsp;"
    wrap_with :div, class: "text-center" do
      [wrap_with(:span, info, class: "count-number clearfix"),
       wrap_with(:span, label, class: "count-label")]
    end
  end
end
