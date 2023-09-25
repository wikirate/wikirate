include_set Abstract::IdList

format :html do
  def placeholder_text
    t :deckorate_attribution_party_placeholder
  end

  view :input, cache: :never do
    card.content = Auth.current_card&.name unless card.content.present?
    super()
  end
end
