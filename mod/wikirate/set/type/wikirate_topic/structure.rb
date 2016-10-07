format :html do
  view :core do
    tabs = [
      [ "company",  "Companies", "_+company+*cached count"],
      [ "overview", "Review", "_+Review+*count"],
      [ "metric",  "Metrics", "_+metric count"],
      [ "note", "Notes", "_+note+*count"],
      [ "reference", "Sources", "_+source+*count"]
    ]
    wikirate_layout "topic", tabs
  end
end

