format :html do
  view :core, unknown: true do
    return super() if card.known?

    unknown_image_icon || ""
  end

  def unknown_image_icon
    return unless code = card.left&.type_code

    mapped_icon_tag code
  end
end
