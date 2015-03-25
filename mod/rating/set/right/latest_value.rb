format :html do
  view :concise do |args|
    latest = search_results.first
    year   = latest.cardname.right
    metric = latest.cardname.left_name.left
    legend = subformat(Card.fetch(metric))._render_legend args
    %{
      <span class="metric-year">
        #{year} =
      </span>
      <span class="metric-value">
        #{latest.raw_content}
      </span>
      <span class="metric-unit">
        #{legend}
      </span>
    }
  end
end
