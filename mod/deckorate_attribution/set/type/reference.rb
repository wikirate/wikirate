
card_accessor :adaptation, type: :pointer
card_accessor :party, type: :list
card_accessor :url, type: :uri
card_accessor :wikirate_title, type: :phrase
card_accessor :subject, type: :pointer

require_field :subject
require_field :adaptation

def ok_to_update
  (Auth.current_id == creator_id) || Auth.current.stewards_all?
end

format :html do
  view :bar_left, template: :haml
  view :attribution_form_bottom, template: :haml, unknown: true

  view :bar_right do
    field_nest :url, view: :url_link
  end

  view :new_buttons do
    [wrap { standard_save_button }, render_attribution_form_bottom]
  end

  view :edit_buttons do
    [render_attributions, super(), render_attribution_form_bottom]
  end

  view :attributions do
    tabs "Rich Text" => { content: render_rich_text_attrib },
         "Plain Text" => { content:  render_plain_text_attrib },
         "HTML" => { content: render_html_attrib }
  end

  view :rich_text_attrib do
    attribution_box { render_attribute }
  end

  view :plain_text_attrib do
    attribution_box { card.format(:text).render_attribute }
  end

  view :html_attrib do
    attribution_box { h render_attribute }
  end

  def attribution_box
    haml :attribution_box, content: yield
  end

  def new_form_opts
    {
      "data-slot-selector": ".TYPE-reference.new_buttons-view",
      success: { view: :attributions }
    }
  end

  def edit_fields
    [
      :subject,
      [:adaptation, title: "Adaptation"],
      [:party, title: "Person or Organization"],
      [:wikirate_title, title: "Title"],
      [:url, title: "URL"]
    ]
  end

  def raw_help_text
    with_nest_mode :normal do
      haml :attribution_message
    end
  end
end

format do
  view :attribute, cache: :never do
    with_nest_mode :normal do
      %i[wikirate title adaptation license].map do |section|
        attribution_section section
      end.compact.join ", "
    end
  end

  view :att_adaptation do
    return unless adaptation?

    adapters = card.party_card.item_names
    return "Adaptation" unless adapters.first.present?

    "Adaptation by #{adapters.to_sentence}"
  end

  def attribution_section section
    if section == :adaptation
      render_att_adaptation
    else
      nest card.subject, view: "att_#{section}"
    end
  end

  def adaptation?
    card.adaptation_card&.first_card&.codename == :yes_adaptation
  end
end
