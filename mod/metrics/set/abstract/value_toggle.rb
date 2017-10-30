format :html do
  def empty_details_slot
    wrap_with(:div, "", id: collapse_id,
                        class: "card-slot collapse answer-details text-muted")
  end

  def row
    wrap_with :div do
      [
        _render_answer_details_toggle,
        value_field
      ]
    end
  end

  def collapse_id
    "#{card.name.safe_key}-answer-details"
  end

  view :answer_details do
    value_details
  end

  view :answer_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 "\
                "btn btn-default btn-sm pull-right"
    wrap_with(:i, "",
              class: css_class,
              data: { toggle: "collapse",
                      url: path(view: :answer_details),
                      target: "##{collapse_id}.answer-details",
                      collapse_icon_in: "fa-caret-down",
                      collapse_icon_out: "fa-caret-right" })
  end
end
