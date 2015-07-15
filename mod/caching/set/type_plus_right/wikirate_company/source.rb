include Card::CachedCount

expired_cached_count_cards do |changed_card|
  if (l=changed_card.left)  && l.type_code == :source &&
     (r=changed_card.right) && r.type_code == :pointer && r.key == 'company'
    changed_card.item_cards
  end
end
