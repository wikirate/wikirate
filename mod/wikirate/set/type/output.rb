card_accessor :image
card_accessor :description
card_accessor :uri, type: :uri
card_accessor :file, type: :file

card_accessor :year, type: :phrase

format :html do
  def edit_fields
    %i[image output_type uri file year description]
  end

  view :box_middle do
    field_nest :image, view: :content
  end

  view :box_bottom, template: :haml
  view :core, template: :haml
end
