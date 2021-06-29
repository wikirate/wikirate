# -*- encoding : utf-8 -*-

class YearApplicability < Cardio::Migration
  def up
    clean_up_list_card

    ensure_card %i[metric year type_plus_right default], content: :list.cardname
    ensure_card %i[metric year type_plus_right input_type], content: "multiselect"

    ensure_card %i[company_group year type_plus_right default], content: :list.cardname
    ensure_card %i[company_group right content_options],
                content: '{"type":"Company Group","sort":"name","dir":"desc","limit":"0"}'
  end

  def clean_up_list_card
    card_named_list = Card["List"]
    return if card_named_list&.codename == :list

    card_named_list&.delete!
    Card[:list].update! name: "List"
  end
end
