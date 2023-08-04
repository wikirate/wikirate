card_accessor :reference, type: :search_type

format :html do
  def bar_menu_items
    # super.insert 2, new_attribution_link(text: "Attribute")
    super.insert 2, attribution_link(text: "Attribute")
  end

  def menu_items
    super.unshift attribution_link
  end

  def attribution_link text: ""
    modal_link "#{attribution_icon} #{text}",
               size: :large,
               path: { mark: card.reference_card, view: :link_and_list }
  end

  def new_attribution_link text: "", button: false
    modal_link "#{attribution_icon} #{text}",
               size: :large,
               class: ("btn btn-primary" if button),
               path: { mark: :reference,
                       action: :new,
                       card: { fields: { ":subject": card.name,
                                         ":party": Auth.current_card&.name } } }
  end

  def attribution_icon
    icon_tag :attribution
  end

  # view :new_attribution_button do
  #
  # end
end
