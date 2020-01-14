include_set Abstract::Researched

def inverse_card
  fetch(:inverse).item_cards.first
end

def inverse
  fetch(:inverse).item_names.first
end

def inverse_title
  (card = fetch([metric_title, :inverse])) && card.item_names.first
end

def relationship?
  true
end

format :html do
  def value_legend _html=true
    "related companies"
  end
end
