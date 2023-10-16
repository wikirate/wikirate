format :html do
  def confirm_export
    :attribution_alert.card.content
    nil
  end

  view :export_button do
    wrap_with :div, class: "_attributable-export" do
      [super(), render_attribution_alert]
    end
  end

  view :attribution_alert, template: :haml
end
