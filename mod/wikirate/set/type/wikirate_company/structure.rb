format :html do
  view :core do |args|
    tabs = [
      ["topic", "Topics", "+topic+*cached count"],
      ["overview", "Reviews", "+analyses with overview+*cached count"],
      ["metric", "Metrics", "+metric+*cached count"],
      ["note", "Notes", "+Note+*cached count"],
      ["reference", "Sources", "+sources+*cached count"]
    ]
    wikirate_layout tabs, "company", render_contribution_link(args)
  end
end