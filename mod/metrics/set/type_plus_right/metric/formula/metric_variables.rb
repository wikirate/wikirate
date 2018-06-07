# handle variables (eg M1, M2, etc) used in a formula card's content

# FIXME: card is getting stored in database (despite being a session card)
def variables_card
  metric_card.metric_variables_card
end

event :replace_variables, :prepare_to_validate, on: :save, changed: :content do
  each_nested_chunk do |chunk|
    next unless variable_name?(chunk.referee_name)
    metric_name = variables_card.input_metric_name chunk.referee_name
    content.gsub! chunk.referee_name.to_s, metric_name if metric_name
  end
end

format :html do
  view :variables do
    nest card.variables_card, view: :edit_in_formula
  end
end
