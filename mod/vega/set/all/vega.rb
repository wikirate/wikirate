format :html do
  basket[:head_views] << :vega_js

  view :vega_js, unknown: true do
    output [javascript_include_tag("https://cdn.jsdelivr.net/npm/vega@5"),
            javascript_include_tag("https://cdn.jsdelivr.net/npm/vega-embed@6")]
  end
end
