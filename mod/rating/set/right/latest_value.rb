format :html do
  view :concise do |args|
    latest = search_results.first
    if latest
      subformat(latest)._render_concise(args)
    else
      ''
    end
  end
end
