include_set CategoryValue

format :html do
  def input_type
    options_count > 10 ? :multiselect : :checkbox
  end
end

format :json do
  view :content do
    card.raw_value
  end
end
