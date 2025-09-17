format :html do
  def confirm_export
    :attribution_alert.card.content
    nil
  end

  view :export_button, cache: :deep do
    wrap_with :div, class: "_attributable-export" do
      [super(), card_stub(view: :attribution_alert,
                          slot: { hide: :pop_out_modal_link },
                          filter: filter_hash_from_params)]
    end
  end

  view :attribution_alert, template: :haml, cache: :yes, wrap: { modal: { size: :large } }

  # for override
  view(:attribution_alert_detail) { "" }
end
