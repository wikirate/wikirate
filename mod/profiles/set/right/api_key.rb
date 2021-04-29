format :html do
  view :titled_content do
    super() + (card.content.present? ? render_api_key_helper : "")
  end

  view :api_key_helper, template: :haml
end
