include_set Abstract::Researched

def inverse_card
  fetch(:inverse).item_cards.first
end

def inverse
  fetch(:inverse).first_name
end

def inverse_title
  Card.fetch([metric_title, :inverse])&.first_name
end

def relationship?
  true
end

format :html do
  def value_legend _html=true
    "related companies"
  end
end
