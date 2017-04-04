include_set Abstract::SolidCache, cached_format: :json

ensure_set { TypePlusRight::Metric::WikirateTopic }

cache_expire_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card[topic_name].fetch(trait: :all_metrics)
  end
end
