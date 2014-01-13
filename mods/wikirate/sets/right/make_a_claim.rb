view :core do |args|
  
  needed_fields = %w{ Link Website Title Topics Companies Markets }.find_all do |field|
    !Card.exists? "#{card.cardname.left}+#{field}"
  end
    
  #return "WOOOTWO"
#  test = Card.search :name=>card.cardname.left, :found_by=>'ready', :return=>'name'
  if needed_fields.any?
    %{
      <div class="wikirate-page-not-ready">
        <h2>Almost Claim-Ready!</h2>
        <div>This page will be ready for claims when it has the following fields: 
          <div class="needed-fields">
            #{needed_fields.map {|f| "<span>#{f}</span>"}.join ", "}
          </div>
        </div>
      </div>
    }
  else
    %{
      <div class="wikirate-page-ready">
        #{ _final_core args }
      </div>
    }
    
  end
end