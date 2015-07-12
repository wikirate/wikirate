CACHED_METRIC_KEY

format :html do
  view :content do |args|
    if (metric = card[1..2]) && metric.type_code == :metric
      key = "view_content_card_#{card.key}_args_#{Card::Cache.obj_to_key args}"
      cached_items = Card::Cache[Card::Set::Right::YinyangDragItem].fetch metric.key, {}
      if !cached_items[key]
        cached_items[key] = super(args)
        Card::Cache[Card::Set::Right::YinyangDragItem].write metric.key, cached_items
      end
      cached_items[key]
    else
      super(args)
    end
  end
end