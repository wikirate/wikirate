
def options_restricted_by_source
  options_card.item_cards :limit=>0, :vars=>{ :source=>wikirate_claim_source }
end

def wikirate_claim_source
  #FIXME - can only handle one source!
  
  if new_card?
    s = Wagn::Env.params['_Source'] and s.to_name.key
  else
    Card["#{name.to_name.trunk_name}+Source"].item_names.first.to_name.key
  end
end