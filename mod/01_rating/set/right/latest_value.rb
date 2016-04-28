def metric_value_card
  @mvc ||= left.respond_to?(:latest_value_card) && left.latest_value_card
end

def raw_content
  if metric_value_card
    metric_value_card.raw_content
  else
    ''
  end
end

format :html do
  view :concise do |args|
    # latest = search_results.first
    # if latest
    #   subformat(latest)._render_concise(args)
    if card.metric_value_card
      subformat(card.metric_value_card)._render_concise(args)
    else
      ''
    end
  end
end
