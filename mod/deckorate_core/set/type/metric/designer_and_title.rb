def tracker_content_groups
  super.merge cg3: metric_designer
end

def metric_designer
  compound? ? name.parts.first.to_name : creator&.name
end

def metric_designer_id
  metric_designer.card_id
end

def metric_designer_card
  compound? ? self[0] : creator
end

def designer_image_card
  metric_designer_card.fetch :image, new: { type: :image }
end

def metric_title
  compound? ? name.parts[1].to_name : name
end

def metric_title_id
  # without second option, title_id fetching breaks on new cards added from ui, in which
  # +:title is a subcard. not sure why. tests will not catch, but don't remove without
  # testing/fixing.
  metric_title.card_id || subcard(metric_title).id
end

def metric_title_card
  compound? ? self[1] : self
end

format :html do
  def google_analytics_snippet_vars
    super.merge contentGroup3: card.metric_designer
  end
end
