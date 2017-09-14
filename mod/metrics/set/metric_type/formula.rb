include Set::Abstract::Calculation

card_accessor :variables, type_id: Card::SessionID

format :html do
  def value_type
    "Number"
  end

  def value_type_code
    :number
  end

  def default_thumbnail_subtitle_args args
    args[:text] ||= ["Formula", "designed by"].compact.join " | "
    args[:author] ||= link_to_card card.metric_designer
  end
end
