format :html do
  def score_input
    custom_variable_input :score_input
  end

  def variables_json
    metric_card.base_input_array.to_json
  end
end
