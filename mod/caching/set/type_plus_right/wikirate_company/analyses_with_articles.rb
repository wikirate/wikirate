include Card::CachedCount

expired_cached_counts :on=>[:create, :delete] do |changed_card|
  if (l=changed_card.left)  && l.type_code == :wikirate_analysis &&
     (r=changed_card.right) && r.codename == :wikirate_article
     l.left
  end
end
