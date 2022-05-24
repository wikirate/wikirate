format :html do
  def unknown_image_icon
    return unless (code = card.left&.type_code)

    mapped_icon_tag code
  end

  view :core do
    return super() if card.known?

    unknown_image_icon || ""
  end
end
