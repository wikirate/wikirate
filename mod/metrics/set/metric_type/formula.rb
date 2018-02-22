include Set::Abstract::Calculation

card_accessor :variables, type_id: Card::SessionID

format :html do
  view :content_formgroup do
    super() +
      field_nest(:hybrid, title: "Hybrid")
  end

  def value_type
    "Number"
  end

  def value_type_code
    :number
  end

  def thumbnail_metric_info
    "Formula"
  end
end
