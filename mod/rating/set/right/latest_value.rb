format :html do
  view :concise do |args|
    latest = search_results.first
    unit = Card.fetch("#{latest.cardname.left_name.left}+unit")
    %{
      <span class="metric-year">
        #{latest.cardname.right} =
      </span>
      <span class="metric-value">
        #{latest.raw_content}
      </span>
      <span class="metric-unit">
        /#{unit.raw_content if unit}
      </span>
    }
  end
end
