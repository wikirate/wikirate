format :html do
  view :concise do |args|
    latest = search_results.first
    %{
      <span class="metric-year">
        #{latest.right.name} =
      </span>
      <span class="metric-value">
        #{latest.raw_content}
      </span>
    }
  end
end