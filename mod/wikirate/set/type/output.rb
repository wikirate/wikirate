card_accessor :image
card_accessor :description
card_accessor :uri, type: :uri
card_accessor :file, type: :file
card_accessor :output_type, type: :pointer

card_accessor :date, type: :date
card_accessor :wikirate_company, type: :pointer

format :html do
  def edit_fields
    %i[image output_type uri file year description]
  end

  view :box_top, template: :haml
  view :box_middle, template: :haml

  view :box_bottom, template: :haml
  view :core, template: :haml
end
