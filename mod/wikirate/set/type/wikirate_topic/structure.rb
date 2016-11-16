format :html do
  view :core do
    tabs = [
        ["company", "Companies", "+company+*cached count"],
        ["overview", "Review", "+Review+*count"],
        ["metric", "Metrics", "+metric count"],
        ["note", "Notes", "+note+*count"],
        ["reference", "Sources", "+source+*count"]
    ]
    wikirate_layout "topic", tabs
  end
end

