include_set Abstract::Breadcrumbs

card_accessor :image
card_accessor :description
card_accessor :uri, type: :uri
card_accessor :file, type: :file
card_accessor :output_type, type: :pointer

card_accessor :date, type: :date
card_accessor :company, type: :pointer

format :html do
  view :page, template: :haml
  view :titled, :page
  view :titled_content, template: :haml

  view :box_top, template: :haml
  view :box_middle, template: :haml
  view :box_bottom, template: :haml

  def breadcrumb_type_item
    link_to_card :wikirate_impact
  end

  def edit_fields
    %i[image output_type uri file date description company]
  end
end
