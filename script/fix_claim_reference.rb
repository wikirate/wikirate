require File.expand_path('../../config/environment',  __FILE__)


Card::Auth.as_bot do

  claim_cards = Card.search :type_id=>Card::ClaimID,:not=>{:right_plus=>[Card[:source].name,{:refer_to=>{:type_id=>Card::SourceID} }]}
  claim_cards.each do |card|
    claim_source = card.fetch :trait=>:source
    if claim_source
      puts claim_source.name
      claim_source.update_references
      claim_source.expire_structuree_references
    end
  end

end