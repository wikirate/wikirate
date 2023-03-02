format :html do
  def badge_icon level
    icon_tag :badge, level
  end

  view :count, unknown: true do
    medal_counts "horizontal"
  end

  def medal_counts klass
    content = [:gold, :silver, :bronze].map { |level| level_count level }
    list_tag content, class: klass
  end

  def level_count level
    "#{badge_icon(level)} #{badge_count(level)}"
  end
end
