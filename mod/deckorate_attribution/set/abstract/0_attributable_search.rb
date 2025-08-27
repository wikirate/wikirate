format :html do
  view :export_button, cache: :deep do
    return super() unless export_ok?

    wrap_with :div, class: "_attributable-export" do
      [super(), render_attribution_alert]
    end
  end

  view :attribution_alert, template: :haml, cache: :yes
end
