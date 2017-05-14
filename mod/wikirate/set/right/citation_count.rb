format :html do
  view :titled do
    class_up "card-slot", "no-citations" if no_citations?
    super()
  end

  def grandparent
    @grandparent ||= parent && (gp = parent.parent) && gp.card
  end

  def no_citations?
    _render_core.to_i.zero?
  end

  def related_overview_card
    Card.fetch card.cardname.left_name.trait(:related_articles)
  end
end
