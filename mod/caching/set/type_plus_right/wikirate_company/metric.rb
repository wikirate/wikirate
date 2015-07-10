include Card::CachedCount

expired_cached_counts :on=>[:create,:delete] do |changed_card|
  if (l=changed_card.left)  && l.type_code == :metric &&
     (r=changed_card.right) && r.type_code == :wikirate_company
     r
  end
end