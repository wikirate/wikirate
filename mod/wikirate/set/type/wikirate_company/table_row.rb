include_set Abstract::Thumbnail

format :html do
  view :metric_count_with_label do
    link_to_metric_count metric_count, "Metrics"
  end

  def topic_card
    @table_context || Card.fetch(filter_param(:wikirate_topic))
  end

  def analysis_card
    Card.fetch [name, topic_card.name]
  end

  def link_to_metric_count count, label
    text = count_with_label_cell count, label
    link_to text, path: { mark: card.name,
                          filter: { wikirate_topic: topic_card.name } }
  end

  def metric_box content, label
    %(
      <div class="content">
        #{content}<div class="name">#{label}</div>
      </div>
    )
  end

  def metric_count
    return 0 unless analysis_card
    metrics = analysis_card.fetch(trait: :metric)
    metrics ? metrics.cached_count : 0
  end

  view :viggles do
    "waiting for vignesh's new thumbnail view"
  end
end
