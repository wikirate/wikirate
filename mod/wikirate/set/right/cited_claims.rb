format :html do
  def citations
    # FIXME: this citation stashing mechanism is a mess
    parent.citations
  end

  view :cited_count, cache: :never do
    if citations.present?
      citations.size
    else
      0
    end
  end

  view :content, cache: :never do
    super()
  end

  view :core, cache: :never do
    if citations.present?
      results = citations.map do |name|
        Card.fetch name, new: { type_id: Card::ClaimID }
      end
      card_list results
    else
      super()
    end
  end

  def card_list results
    items = results.each_with_index.map do |claim, num|
      citation_number = %(<span class="cited-claim-number">#{num + 1}</span>)
      nest claim, citation_number: citation_number do |rendered, item_view|
        %(<div class="search-result-item item-#{item_view}">#{rendered}</div>)
      end
    end.join
    %(<div class="search-result-list">#{items}</div>)
  end
end
