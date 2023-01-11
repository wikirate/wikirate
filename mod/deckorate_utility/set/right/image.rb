format :html do
  def unknown_image_icon
    l = card.left
    return unless (code = l&.codename || l&.type_code)

    mapped_icon_tag code
  end

  view :core, unknown: true do
    return super() if card.known?

    unknown_image_icon || ""
  end
end
