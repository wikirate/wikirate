format :html do
  def analysis_name
    @analysis_name ||= card.cardname.left_name
  end

  def link_to_metric_count content, label
    text = metric_box content, label
    company = analysis_name.left_name
    topic = analysis_name.right_name
    link_to text, path: { mark: company, wikirate_topic: topic }
  end

  def metric_box content, label
    %(
      <div class="content">
        #{content}<div class="name">#{label}</div>
      </div>
    )
  end

  def metric_count
    return 0 unless Card.fetch analysis_name
    metrics = Card.fetch analysis_name.trait(:metric)
    metrics ? metrics.cached_count : 0
  end

  view :core do |_args|
    content_tag :div, class: "contribution" do
      link_to_metric_count metric_count, "Metrics"
    end
  end
end
