format :html do
  def certificate level
    fa_icon :certificate, level
  end

  view :count, unknown: true do
    medal_counts "horizontal"
  end

  def medal_counts klass
    content = [:gold, :silver, :bronze].map { |level| level_count level }
    list_tag content, class: klass
  end

  def level_count level
    "#{certificate(level)} #{badge_count(level)}"
  end
end
