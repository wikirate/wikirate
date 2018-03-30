event :reset_metrics_set_pattern_for_metric_type, :finalize, on: :save do
  left.reset_patterns
  left.include_set_modules
end

format :html do
  view :radio do
    input_name = "pointer_radio_button-#{card.key}"
    options = card.option_names.map do |option_name|
      checked = (option_name == card.item_names.first)
      id = "pointer-radio-#{option_name.to_name.key}"
      <<-HTML
        <li class="pointer-radio radio">
          <label for="#{id}" class="radio-inline">
            #{radio_button_tag input_name, option_name, checked,
                               id: id, class: 'pointer-radio-button'}
            #{radio_label option_name}
          </label>
          #{radio_description option_name}
        </li>
      HTML
    end.join("\n")

    %(<ul class="pointer-radio-list">#{options}</ul>)
  end

  def radio_label option_name
    ((o_card = Card.fetch(option_name)) && o_card.label) || option_name
  end

  def radio_description option_name
    description = pointer_option_description option_name
    return unless description
    "<div class=\"radio-option-description\">#{description}</div>"
  end
end
