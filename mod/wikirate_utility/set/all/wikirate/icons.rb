ICON_MAP = {
  wikirate_company: :business,
  wikirate_topic: :widgets,
  project: [:flask, { library: :font_awesome }],
  subproject: [:flask, { library: :font_awesome }],
  metric: ["bar-chart", { library: :font_awesome }],
  researcher: [:user, { library: :font_awesome }],
  user: [:user, { library: :font_awesome }],
  post: :insert_comment,
  details: :info,
  source: :public,
  score: :adjust,
  year: [:calendar, { library: :font_awesome }],
  research_group: [:users, { library: :font_awesome }],
  contributions: [:plug, { library: :font_awesome }],
  activity: :directions_run,
  program: :extension
}.freeze

format :html do
  def icon_map key
    val = ICON_MAP[key]
    val.is_a?(Array) ? val.map(&:clone) : val
  end
end
