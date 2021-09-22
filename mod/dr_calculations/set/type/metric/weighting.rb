# special metric views used in the context of a wikirating

format :html do
  # TODO: hamlize
  def weight_row weight=0, label=nil
    label ||= _render_thumbnail_no_link
    weight = weight_content weight
    output([wrap_with(:td, label, class: "metric-label"),
            wrap_with(:td, weight, class: "metric-weight")]).html_safe
  end

  def weight_content weight
    icon_class = "float-right _remove-weight btn btn-outline-secondary btn-sm"
    wrap_with :div do
      [text_field_tag("pair_value", weight) + "%",
       content_tag(:span, fa_icon(:close).html_safe, class: icon_class)]
    end
  end
end
