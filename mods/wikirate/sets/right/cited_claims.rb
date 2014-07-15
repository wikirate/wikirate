
format :html do
  view :core do |args|
    if parent.citations.present?
      results = parent.citations.map do |name|
        Card.fetch name, :new=> { :type_id=>Card::ClaimID }
      end
      card_list results, args
    else
      super args
    end
  end
  
  def card_list results, args
    items = (results.each_with_index.map do |claim, num|
      citation_number = %{<span class="cited-claim-number">#{ num + 1 }</span>}
      item = nest claim, :title_icon=>citation_number
      %{<div class="search-result-item item-#{ inclusion_defaults[:view] }">#{ item}</div>}
    end.join )   
    %{<div class="search-result-list">#{items}</div>}
  end
  
end  