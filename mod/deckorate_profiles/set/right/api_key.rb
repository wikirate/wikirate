format :html do
  view :content, unknown: true do
    wrap do
      [render_core, render_api_key_helper]
    end
  end

  view :api_key_helper, unknown: true, template: :haml
end
