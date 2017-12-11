format :html do
  def certificate level
    fa_icon :certificate, level
  end

  view :count, tags: :unknown_ok do |args|
    content = [:gold, :silver, :bronze].map { |level| level_count level }
    list_tag content, class: args[:class] || "horizontal"
  end

  def level_count level
    "#{certificate(level)} #{badge_count(level)}"
  end
end
