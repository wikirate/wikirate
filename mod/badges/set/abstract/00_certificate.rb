format :html do
  def certificate level
    glyphicon :certificate, level
  end

  view :count do
    content = [:gold, :silver, :bronze].map { |level| level_count level }
    list_tag content, class: "horizontal"
  end

  def level_count level
    "#{certificate(level)} #{badge_count(level)}"
  end
end
