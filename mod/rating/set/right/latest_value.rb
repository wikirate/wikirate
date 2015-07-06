format :html do
  view :concise do |args|
    latest = search_results.first
    if latest
      subformat(latest)._render_concise(args)
    # if card.left.respond_to?(:latest_value_card) && (lvc = card.latest_value_card)
    #  subformat(lvc)._render_concise(args)
    else
      ''
    end


  end
end


