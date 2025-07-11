include_set Abstract::ReadOnly

def infer
  update content: compatible(left.metric_card.item_cards.map(&:license))
end
