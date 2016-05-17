format :html do
  view :titled do |args|
    args[:slot_class] = ("no-citations" if no_citations?(args))
    super(args)
  end

  view :related_overview_modal_box do |args|
    content_tag :div do
      subformat(related_overview_card)
        ._render_modal_link(args[:link_args])
    end
  end

  def default_related_overview_modal_box_args args
    link_text = subformat(card).render_titled(
      args.merge(title: "Citations", hide: "menu")
    )
    link_args = args[:link_args] =
                  args.merge(
                    text: link_text,
                    html_args: { class: ("no-citations" if no_citations?(args)).to_s }
                  )
    return unless (company = on_company_page?)
    link_args[:path_opts] ||= {}
    link_args[:path_opts][:company] = company.key
    link_args[:path_opts][:general_overview] = true
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
