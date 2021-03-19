format :html do
  def views_in_head
    super << :vega_embed_js
  end

  view :vega_embed_js do
    javascript_include_tag "https://cdn.jsdelivr.net/npm/vega-embed@6"
  end
end