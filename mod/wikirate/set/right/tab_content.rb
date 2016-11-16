format :html do
  view :core, cache: :never do
    # show the content based on the url parameter
    # tabs: metric, topic, company, note, reference, overview
    tab = Env.params["tab"]
    left_name = card.cardname.left
    card_tab_name =
      if !tab.nil?
        "#{left_name}+#{tab}_page"
      else
        "#{left_name}+metric_page"
      end
    if (content_card = Card.fetch card_tab_name)
      subformat(content_card).render_content
    else
      ""
    end
  end
end
