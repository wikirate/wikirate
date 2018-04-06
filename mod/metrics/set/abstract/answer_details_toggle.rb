format :html do
  def empty_details_slot
    wrap_with :div, "", id: collapse_id, class: "card-slot collapse answer-details"
  end

  view :details do
    voo.hide :expanded_details
    basic_details + expanded_details
  end

  def basic_details
    wrap_with :div do
      output [answer_details_toggle, render_basic_details]
    end
  end

  def expanded_details
    if voo.show? :expanded_details
      render :expanded_details
    else
      empty_details_slot
    end
  end

  def collapse_id
    "#{card.name.safe_key}-answer-details"
  end

  def answer_details_toggle
    wrap_with(:button, "",
              class: "fa fa-caret-right fa-lg margin-left-10 " \
                     "btn btn-outline-secondary btn-sm pull-right",
              data: { toggle: "collapse",
                      url: path(view: :expanded_details),
                      target: ".answer-details##{collapse_id}",
                      collapse_icon_in: "fa-caret-down",
                      collapse_icon_out: "fa-caret-right" })
  end
end
