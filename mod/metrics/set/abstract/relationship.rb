include_set Abstract::Researched

def inverse_card
  fetch(trait: :inverse).item_cards.first
end

def inverse
  fetch(trait: :inverse).item_names.first
end

def inverse_title
  (card = fetch([metric_title, :inverse])) && card.item_names.first
end

format :html do
  view :legend do
    "companies"
  end
end
