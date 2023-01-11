# default is material

ICON_MAP = {
  wikirate_company: [:company, { library: :svg }],
  wikirate_topic: [:topic, { library: :svg }],
  company_group: [:company_group, { library: :svg }], # city not available in 4.7
  project: [:project, { library: :svg }],
  dataset: [:dataset, { library: :svg }],
  data_subset: [:dataset, { library: :svg }],
  metric: [:metric, { library: :svg }],
  record: ["bar-chart", { library: :font_awesome }],
  metric_answer: ["clipboard-check", { library: :font_awesome }],
  researcher: [:user, { library: :font_awesome }],
  user: [:user, { library: :font_awesome }],
  simple_account: [:user, { library: :font_awesome }],
  post: :insert_comment,
  bookmark: [:bookmark, { library: :font_awesome }],
  bookmarks: [:bookmark, { library: :font_awesome }],
  details: ["info-circle", { library: :font_awesome }],
  source: [:source, { library: :svg }],
  preview: ["file-pdf", { library: :font_awesome }],
  score: :adjust,
  answer_import: :input,
  metric_import: :input,
  calculation: [:calculator, { library: :font_awesome }],
  year: [:"calendar-alt", { library: :font_awesome }],
  research_group: [:research_group, { library: :svg }],
  contributions: [:plug, { library: :font_awesome }],
  activity: :directions_run,
  community_assessed: [:unlock, { library: :font_awesome }],
  designer_assessed: [:lock, { library: :font_awesome }],
  dashboard: ["tachometer-alt", { library: :font_awesome }],
  task: [:tasks, { library: :font_awesome }]
}.freeze

format :html do
  def icon_map key
    val = ICON_MAP[key]
    val.is_a?(Array) ? val.map(&:clone) : val
  end

  def mapped_icon_tag key
    return unless key.present? && (icon_args = icon_map(key))
    icon_tag(*Array.wrap(icon_args))
  end

  def icon_labeled_field field, item_view=:name, opts={}
    field_nest field, opts.merge(view: :labeled,
                                 items: (opts[:items] || {}).merge(view: item_view))
  end

  def svg_icon_tag _icon, _opts={}
    "not implemented"
  end
end
