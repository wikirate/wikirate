def metric_designer
  compound? ? name.parts.first.to_name : creator.name
end

def metric_designer_id
  metric_designer.card_id
end

def metric_designer_card
  compound? ? self[0] : creator
end

def designer_image_card
  metric_designer_card.fetch(:image, new: { type_id: Card::ImageID })
end

def metric_title
  compound? ? name.parts[1].to_name : name
end

def metric_title_id
  metric_title.card_id
end

def metric_title_card
  compound? ? self[1] : self
end
