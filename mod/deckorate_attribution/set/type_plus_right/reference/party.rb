include_set Abstract::IdList

format :html do
  def placeholder_text
    t :deckorate_attribution_party_placeholder
  end

  view :input, cache: :never do
    card.content = Auth.current_card&.name if Auth.signed_in? && card.content.blank?
    super()
  end

  def help_text
    t :deckorate_attribution_party_help_text
  end
end
