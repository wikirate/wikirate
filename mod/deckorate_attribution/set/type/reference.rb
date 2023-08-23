
card_accessor :adaptation, type: :pointer
card_accessor :party, type: :phrase
card_accessor :url, type: :uri
card_accessor :wikirate_title, type: :phrase
card_accessor :subject, type: :pointer

def ok_to_update
  (Auth.current_id == creator_id) || Auth.current.stewards_all?
end

format :html do
  def edit_fields
    [
      :subject,
      [:adaptation, title: "Adaptation"],
      [:party, title: "Person or Organization"],
      [:wikirate_title, title: "Title"],
      [:url, title: "URL"]
    ]
  end

  view :bar_left, template: :haml

  view :bar_right do
    field_nest :url, view: :url_link
  end

  def new_form_opts
    {
      "data-slot-selector": ".TYPE-reference.new_buttons-view",
      success: { view: :attributions }
    }
  end

  view :new_buttons, wrap: :slot do
    standard_save_button
  end

  view :attributions do
    nest card.subject, view: :attributions
  end
end
