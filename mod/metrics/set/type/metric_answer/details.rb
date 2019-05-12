format :html do
  # ANSWER DETAILS ON RECORDS
  # company and/or metrics are detailed separately,
  # so details only include value, year, etc.

  # TODO: move to haml
  view :basic_details do
    wrap_with :div, class: "value text-align-left" do
      [
        nest(card.value_card, view: :pretty_link),
        wrap_with(:span, legend, class: "metric-unit"),
        _render_flags,
        _render_chart
      ]
    end
  end

  view :details do
    if card.relationship?
      voo.hide! :answer_details_toggle
      voo.show! :expanded_details
    else
      class_up "vis", "pull-right"
    end
    super()
  end

  # concept
  #
  # view :core do
  #   output [#
  #     render_metric_listing,
  #     render_company_listing,
  #     render_answer_table
  #   ]
  # end

  # view :expanded_from_company do
  #   render :core, hide: :company_listing
  # end

  # view :expanded_from_metric do
  #   render :core, hide: :metric_listing
  # end

  # view :metric_listing do
  #   nest metric_card, view: :listing
  # end

  # view :company_listing do
  #   nest company_card, view: :listing
  # end

end
