format :html do
  view :open_profile do
    _render_open
  end

  view :title do
    title = super()
    title += title_icon if voo.home_view == :open_profile
    title
  end

  def title_icon
    # FIXME: codename!
    icon_card = card.field "icon"
    icon_card ? "<i class='fa fa-#{icon_card.content}></i>" : ""
  end
end
