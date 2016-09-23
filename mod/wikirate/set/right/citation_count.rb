format :html do
  view :titled do |args|
    args[:slot_class] = ("no-citations" if no_citations?(args))
    super(args)
  end

  def on_company_page?
    return unless parent && (pp = parent.parent) && (ppc = pp.card)
    return ppc if ppc.type_id == WikirateCompanyID
    return unless (ppl = ppc.left) && ppl.type_id == WikirateCompanyID
    ppl
  end

  def no_citations? args
    value = _render_core args
    value == "0" || value == ""
  end

  def related_overview_card
    Card.fetch card.cardname.left_name.trait(:related_articles)
  end
end
