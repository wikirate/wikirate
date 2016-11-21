format :html do
  view :core do
    return super() if voo.structure
    wikirate_layout "topic",
                    [["company", "Companies", "+company+*cached count"],
                     ["overview", "Review", "+Review+*count"],
                     ["metric", "Metrics", "+metric count"],
                     ["note", "Notes", "+note+*count"],
                     ["reference", "Sources", "+source+*count"]]
  end
end
