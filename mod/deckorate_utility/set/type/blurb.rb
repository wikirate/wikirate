include_set Abstract::Flipper

card_accessor :icon, type: :phrase
card_accessor :title, type: :phrase
card_accessor :uri, type: :phrase
card_accessor :body

format :html do
  def edit_fields
    %i[icon title uri body]
  end

  view :core do
    render_box
  end

  view :box_top do
    field_nest :title, view: :core
  end

  view :box_middle do
    field_nest :icon, view: :core
  end

  view :bar_left do
    [field_nest(:right, view: :core, size: :small),
     field_nest(:title, view: :core)]
  end

  view :stack, template: :haml, wrap: :slot
  view :head_and_lead, template: :haml
  view :icon_left_text_right, template: :haml

  view :flipper_title, template: :haml
  view :flipper_body, template: :haml

  view :action_card, template: :haml
  view :cta, template: :haml
  view :cta_section, template: :haml
end
