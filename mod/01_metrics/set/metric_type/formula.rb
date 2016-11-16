include Set::Abstract::Calculation

card_accessor :variables, type_id: Card::SessionID

format :html do
  def value_type
    "Number"
  end
end
