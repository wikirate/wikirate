# handle variables used in a formula card's content

def variables_card
  v_card = metric_card.fetch trait: :variables, new: { type: "session" }
  v_card.content = input_names.to_pointer_content if v_card.content.blank?
  v_card
end

event :replace_variables, :prepare_to_validate,
      on: :save, changed: :content do
  each_nested_chunk do |chunk|
    next unless variable_name?(chunk.referee_name)
    metric_name = variables_card.input_metric_name chunk.referee_name
    content.gsub! chunk.referee_name.to_s, metric_name if metric_name
  end
end

format :html do
  view :variables do |_args|
    with_nest_mode(:normal) do
      nest card.variables_card, view: :open, hide: [:header, :menu]
    end
  end
end
