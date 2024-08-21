card_reader :featured

format :html do
  def featured_header
    "Featured"
  end

  view :featured_boxes, template: :haml
end