include_set Abstract::Slider

card_reader :featured

format :html do
  view :featured_boxes, template: :haml

  def featured_label
    @featured_label || card.name.vary(:plural).downcase
  end

  def featured_header
    "Featured #{featured_label}"
  end

  def featured_link_text
    "View all #{featured_label}"
  end

  def featured_link_path
    path
  end

  def featured_card_boxes
    nest card.featured_card, :flex_centered_boxes
  end
end
