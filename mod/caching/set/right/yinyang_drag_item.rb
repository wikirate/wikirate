
def cache
  Card::Cache[Card::Set::Right::YinyangDragItem]
end

format :html do
  view :content do |args|
    if (metric = card[1..2]) && metric.type_code == :metric
      key = "view_content_card_#{card.key}_args_#{Card::Cache.obj_to_key args}"
      cached_items = cache.read(metric.key) || {}
      if !cached_items[key]
        cached_items[key] = super(args)
        cache.write metric.key, cached_items
      end
      cached_items[key]
    else
      super(args)
    end
  end
end



