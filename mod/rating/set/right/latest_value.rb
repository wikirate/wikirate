format :html do
  view :concise do |args|
    latest = search_results.first
    legend =
      if (unit = Card.fetch("#{latest.cardname.left_name.left}+unit"))
        unit.raw_content
      elsif (range = Card.fetch("#{latest.cardname.left_name.left}+range"))
        "/#{range.raw_content}"
      end
    %{
      <span class="metric-year">
        #{latest.cardname.right} =
      </span>
      <span class="metric-value">
        #{latest.raw_content}
      </span>
      <span class="metric-unit">
        #{legend if legend}
      </span>
    }
  end
end
