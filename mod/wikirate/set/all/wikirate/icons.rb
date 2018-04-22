ICON_MAP = {
  wikirate_company: :business,
  wikirate_topic: :widgets,
  project: [:flask, { library: :font_awesome }],
  subproject: [:flask, { library: :font_awesome }],
  metric: ["bar-chart", { library: :font_awesome }],
  researcher: [:user, { library: :font_awesome }],
  post: :insert_comment,
  details: :info,
  source: :public,
  score: :network_cell,
  year: :calendar,
  research_group: [:users, { library: :font_awesome }],
  contributions: :grain,
  activity: [:plug, { library: :font_awesome }]
}

format :html do
  def icon_map key
    ICON_MAP[key]
  end
end
