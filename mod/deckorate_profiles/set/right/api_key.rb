format :html do
  view :content, unknown: true do
    wrap do
      [render_core, (card.content.present? ? render_api_key_helper : "")]
    end
  end

  view :api_key_helper, template: :haml
end
