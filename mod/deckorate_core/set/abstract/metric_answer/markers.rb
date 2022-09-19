include_set Abstract::Flaggable

delegate :open_flags, to: :lookup

format :html do
  view :markers do
    markers
  end

  view :small_markers do
    markers.map { |marker| "<small>#{marker}</small>" }
  end

  def marker_names
    [:comment]
  end

  def markers
    marker_names.map { |marker_name| send "#{marker_name}_marker" }
  end

  def comment_marker
    # the following will work once relationships have answer lookups
    # return "" unless card.lookup&.comments&.present?
    # fa_icon :comment, title: "Has comments"
    field_nest :discussion, view: :marker
  end
end
