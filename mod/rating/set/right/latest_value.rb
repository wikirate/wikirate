format :html do
  view :concise do |args|
    latest = search_results.first
    if latest
      year   = latest.cardname.right
      metric = latest.cardname.left_name.left
      value  = Card.fetch "#{latest.name}+value"
      legend = subformat(Card.fetch(metric))._render_legend args
      %{
        <span class="metric-year">
          #{year} =
        </span>
        <span class="metric-value">
          #{value.raw_content}
        </span>
        <span class="metric-unit">
          #{legend}
        </span>
      }
    else
      ''
    end
  end
end
