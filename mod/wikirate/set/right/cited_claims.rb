
format :html do
  view :cited_count do
    if parent.citations.present?
      parent.citations.size
    else
      0
    end
  end
  view :core do |args|
    if parent.citations.present?
      results = parent.citations.map do |name|
        Card.fetch name, new: { type_id: Card::ClaimID }
      end
      card_list results, args
    else
      super args
    end
  end

  def card_list results, _args
    items = results.each_with_index.map do |claim, num|
      citation_number = %(<span class="cited-claim-number">#{num + 1}</span>)
      item = nest claim, citation_number: citation_number
      <<-HTML
        <div class="search-result-item item-#{nest_defaults(claim)[:view]}">
          #{item}
        </div>
      HTML
    end.join
    %(<div class="search-result-list">#{items}</div>)
  end
end
