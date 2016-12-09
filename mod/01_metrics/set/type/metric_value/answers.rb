format :html do
  view :closed_answer do
    wrap_with :div, class: "td value" do
      [
        wrap_with(:span, currency, class: "metric-unit"),
        _render_value_link,
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags,
        _render_chart,
        _render_answer_details_toggle
      ]
    end
  end

  view :flags do
    output [
             checked_value_flag,
             comment_flag
           ]
  end

  view :answer_details do

  end

  view :answer_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 btn btn-default btn-sm"
    wrap_with(:i, "", class: css_class,
              data: { toggle: "collapse-next",
                      parent: ".value",
                      collapse: ".metric-value-details"
              }
    )
  end

  view :plain_year do
    card.cardname.right
  end

end
