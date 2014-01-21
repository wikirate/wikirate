view :core do |args|
  
  claim_card = Card.new :type_id=>Card::ClaimID
  f = subformat claim_card
  f.render_new :type=>'Claim', :structure=>card.name, :hidden=>{ 
    :success=>'REDIRECT:_self', :quick_claim=>true
  }
  
end