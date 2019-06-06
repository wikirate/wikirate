format :html do
  view :boxed, unknown: true do
    image_box { render_core }
  end

  view :boxed_link, unknown: true do
    image_box { link_to_card card.name.left, render_core }
  end

  def image_box
    wrap_with :div, title: image_title, class: "image-box icon mt-1 align-self-start" do
      yield
    end
  end

  def image_title
    voo.title || card.name.left
  end

  def unknown_image_icon
    return unless (code = card.left&.type_code)

    mapped_icon_tag code
  end

  view :core do
    return super() if card.known?

    unknown_image_icon || ""
  end
end
