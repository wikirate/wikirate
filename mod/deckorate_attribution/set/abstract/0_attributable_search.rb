format :html do
  def confirm_export
    :attribution_alert.card.content
    nil
  end

  view :export_button, cache: :deep do
    wrap_with :div, class: "_attributable-export" do
      [super(), render_attribution_alert]
    end
  end

  view :attribution_alert, template: :haml, cache: :yes

  view :attribution_alert_detail do
    "from AttributionSearch (blah)"
  end

end
