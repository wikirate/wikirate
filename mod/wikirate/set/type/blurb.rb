card_accessor :image
card_accessor :title, type: :phrase
card_accessor :body

format :html do
  def edit_fields
    %i[image title body]
  end

  view :core do
    render_box
  end

  view :box_top do
    field_nest :title, view: :core
  end

  view :box_middle do
    field_nest :image, view: :core
  end

  view :bar_left do
    [field_nest(:image, view: :core, size: :small),
     field_nest(:title, view: :core)]
  end

  view :stack, template: :haml, wrap: :slot
end
