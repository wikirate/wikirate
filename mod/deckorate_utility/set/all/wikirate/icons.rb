basket[:icons][:material].merge!(
  post: :insert_comment,
  score: :adjust,
  answer_import: :input,
  metric_import: :input,
  activity: :directions_run,
  record: :bar_chart,
  metric_answer: :inventory,
  researcher: :person,
  user: :person,
  simple_account: :person,
  bookmark: :bookmark,
  bookmarks: :bookmark,
  details: :info,
  preview: :picture_as_pdf,
  calculation: :calculate,
  year: :calendar_today,
  contributions: :power,
  community_assessed: :lock_open,
  designer_assessed: :lock,
  dashboard: :speed,
  task: :task,
  badge: :emoji_events,
  comment: :comment,
  nav_menu: :menu,
  flagged: :flag,
  community_verified: :check_circle,
  steward_verified: :check_circle,
  download: :file_download,
  upload: :file_upload,
  greater_than: :chevron_right,
  less_than: :chevron_left,
  check: :check,
  more: :more_horiz,
  circle: :circle
)

basket[:icons][:font_awesome].merge!(
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
  badge: :certificate,
  nav_menu: :bars,
  comment: :comments,
  flagged: :flag,
  community_verified: "check-circle",
  steward_verified: "check-circle",
  download: :download,
  upload: :upload,
  check: :check,
  more: "ellipsis-h",
  circle: :circle,
  greater_than: "chevron-right",
  less_than: "chevron-left"
)

format :html do
  def icon_libraries
    %i[wikirate material]
  end

  def icon_labeled_field field, item_view=:name, opts={}
    field_nest field, opts.merge(view: :labeled,
                                 items: (opts[:items] || {}).merge(view: item_view))
  end
end
