format :html do
  def bar_menu_items
    super.insert 2, attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def attribution_link text: ""
    link_to_card :admin, "#{attribution_icon} #{text}"
  end

  def attribution_icon
    icon_tag :attribution
  end
end
