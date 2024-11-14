include_set Abstract::Flaggable

delegate :open_flags, to: :lookup

format :html do
  view :markers, template: :haml

  def marker_names
    %i[comment route]
  end

  def markers
    marker_names.map { |marker_name| send "#{marker_name}_marker" }.select(&:present?)
  end

  def comment_marker
    # the following will work once relationships have answer lookups
    # return "" unless card.lookup&.comments&.present?
    field_nest :discussion, view: :marker
  end

  def route_marker
    route = card.lookup.route_symbol
    return "" if route == :direct

    icon_tag route, title: route
  end
end
