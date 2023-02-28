basket[:icons][:material].merge!(
  post: :insert_comment,
  score: :adjust,
  answer_import: :input,
  metric_import: :input,
  activity: :directions_run,
)

basket[:icons][:font_awesome].merge!(
  record: "bar-chart",
  metric_answer: "clipboard-check",
  researcher: :user,
  user: :user,
  simple_account: :user,
  bookmark: :bookmark,
  bookmarks: :bookmark,
  details: "info-circle",
  preview: "file-pdf",
  calculation: :calculator,
  year: "calendar-alt",
  contributions: :plug,
  community_assessed: :unlock,
  designer_assessed: :lock,
  dashboard: "tachometer-alt",
  task: :tasks,
)

format :html do
  def icon_labeled_field field, item_view=:name, opts={}
    field_nest field, opts.merge(view: :labeled,
                                 items: (opts[:items] || {}).merge(view: item_view))
  end
end
