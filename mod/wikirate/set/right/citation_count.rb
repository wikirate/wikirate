format :html do
  view :titled do |args|
    args.merge! slot_class: ('no-citations' if no_citations?(args))
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
             args.merge(title: "Citations", hide: 'menu')
           )
    link_args = args[:link_args] =
      args.merge(
        text: link_text,
        html_args: { class: "#{'no-citations' if no_citations?(args)}" }
      )
    return unless parent && (pp = parent.parent) && (ppl = pp.card.left) &&
                  ppl.type_id == WikirateCompanyID
    link_args[:path_opts] ||= {}
    link_args[:path_opts][:company] = ppl.key
  end

  def no_citations? args
    value = _render_core args
    value == '0' || value == ''
  end

  def related_overview_card
    Card.fetch "#{card.cardname.left}+#{Card[:related_articles]}"
  end
end
