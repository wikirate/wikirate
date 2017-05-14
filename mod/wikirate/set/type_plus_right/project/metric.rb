include_set Abstract::Table

def project_name
  cardname.left
end

def metric_project_card metric_card
  Card.fetch metric_card.name, project_name, new: {}
end

format :html do
  view :core do
    wrap_with :div, class: "progress-bar-table" do
      wikirate_table :metric,
                     all_metric_project_cards,
                     [:metric_thumbnail, :research_progress_bar],
                     header: ["Metric", "Companies Researched"],
                     td: { classes: ["company"] }
    end
  end

  def all_metric_project_cards
    card.item_cards.map do |metric|
      next unless metric.type_id == MetricID
      card.metric_project_card(metric)
    end.compact
  end
end
