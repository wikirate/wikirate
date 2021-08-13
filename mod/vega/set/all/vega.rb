format :html do
  def views_in_head
    super << :vega_js
  end

  view :vega_js do
    output [javascript_include_tag("https://cdn.jsdelivr.net/npm/vega@5"),
            javascript_include_tag("https://cdn.jsdelivr.net/npm/vega-embed@6")]
  end
end
