format :html do
  def confirm_export
    :attribution_alert.card.content
    nil
  end
  view :export_button do
    wrap_with :div, class: "_attributable-export" do
      [super(), render_hidden_attribution_alert_link]
    end
  end

  view :hidden_attribution_alert_link, template: :haml

  view :attribution_alert, template: :haml
end
