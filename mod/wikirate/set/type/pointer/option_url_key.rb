format :html do
  # overriding default option value name with url_key
  view :multiselect do |_args|
    option_key = card.option_cards.map do |item|
      [item.cardname, item.cardname.url_key]
    end
    selected_option = card.item_names.map do |item|
      item.to_name.url_key
    end
    select_tag(
      "pointer_multiselect",
      options_for_select(option_key, selected_option),
      multiple: true, class: "pointer-multiselect form-control"
    )
  end
end
