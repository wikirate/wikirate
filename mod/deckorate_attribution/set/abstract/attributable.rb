card_accessor :reference, type: :search

format :html do
  def bar_menu_items
    super.insert 2, new_attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def attribution_link text: ""
    link_to_card :admin, "#{attribution_icon} #{text}"
  end

  def new_attribution_link text: ""
    link_to_card :reference, "#{attribution_icon} #{text}",
                 path: { action: :new,
                         card: { fields: { ":subject": card.name,
                                           ":party": Auth.current_card&.name } } }
  end

  def attribution_icon
    icon_tag :attribution
  end
end
