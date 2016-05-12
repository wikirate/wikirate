
format :html do
  def yycache
    Card::Cache[Card::Set::Right::YinyangDragItem]
  end

  def metric_card
    @metric ||= extract_metric_card
  end

  view :content do |args|
    # cache cleaning refers to  contributions.rb#contributees
    if (metric = metric_card)
      key = "view_content_card_#{card.key}_args_#{Card::Cache.obj_to_key args}"
      cached_items = yycache.read(metric.key) || {}
      unless cached_items[key]
        cached_items[key] = super(args)
        yycache.write metric.key, cached_items
      end
      cached_items[key]
    else
      super(args)
    end
  end
end
