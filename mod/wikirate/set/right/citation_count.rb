format :html do
  view :titled do |args|
    args.merge!(:slot_class=>( "no-citations" if card.format.render_core=="0" ))
    super(args)
  end
  view :related_overview_modal_box do |args|
    value = _render_core args
    related_article_card = Card.fetch card.cardname.left+"+related article"
    text = subformat(card).render_titled args.merge({:title=>"Citations",:hide=>"menu"})
    related_article_link = subformat(related_article_card)._render_modal_link(args.merge(:text=>text,:html_args=>{:class=>"#{"no-citations" if value==""}"}))
    content_tag(:div, related_article_link)
  end
end
