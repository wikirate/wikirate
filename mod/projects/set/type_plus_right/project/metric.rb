include_set Abstract::Table

def project_name
  name.left
end

def metric_project_card metric_name
  Card.fetch metric_name, project_name, new: {}
end

def valid_metric_cards
  @valid_metric_cards ||=
    item_cards.select do |metric|
      metric.type_id == MetricID
    end
end

def all_metric_project_cards
  valid_metric_cards.map do |metric|
    metric_project_card metric.name
  end
end

format :html do
  def default_item_view
    :listing
  end

  def editor
    :list
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  view :core do
    wrap_with :div, class: "progress-bar-table" do
      metric_progress_table
    end
  end

  def metric_progress_table
    wikirate_table :metric,
                   card.all_metric_project_cards,
                   [:metric_thumbnail, :research_progress_bar],
                   header: ["Metric", "Companies Researched"],
                   td: { classes: ["company"] }
  end
end
