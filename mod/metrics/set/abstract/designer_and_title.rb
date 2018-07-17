def metric_designer
  junction? ? name.parts[0] : creator.name
end

def metric_designer_card
  junction? ? self[0] : creator
end

def designer_image_card
  metric_designer_card.fetch(trait: :image, new: { type_id: ImageID })
end

def metric_title
  junction? ? name.parts[1] : name
end

def metric_title_card
  junction? ? self[1] : self
end

format :html do
  def designer_image
    nest card.metric_designer_card.field(:image, new: {}),
         view: :core, size: :small
  end

  view :designer_image do
    designer_image
  end

  def designer_image_link
    link_to_card card.metric_designer_card, designer_image
  end
end
