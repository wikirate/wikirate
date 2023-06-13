# -*- encoding : utf-8 -*-

class YearApplicability < Cardio::Migration::Transform
  def up
    clean_up_list_card

    # TODO: move to core?
    ensure_card %i[list type input_type], content: 'list'

    ensure_card %i[metric year type_plus_right default], type_code: :list, content: ""
    ensure_card %i[metric year type_plus_right input_type], content: "multiselect"

    ensure_card %i[metric company_group type_plus_right default],
                type_code: :list, content: ""
    ensure_card %i[company_group right content_options],
                type_code: :search_type,
                content: '{"type":"Company Group","sort_by":"name","dir":"desc","limit":"0"}'
  end

  def clean_up_list_card
    card_named_list = Card["List"]
    return if card_named_list&.codename == :list

    card_named_list&.delete!
    Card[:list].update! name: "List"
  end
end
