format :html do
  def select_input_options
    options = { "" => ["-- Select --"] }.merge card.options_hash
    grouped_options_for_select options, card.first_name
  end
end
