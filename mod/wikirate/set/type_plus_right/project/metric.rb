def project_name
  cardname.left
end

def metric_project_card metric_card
  Card.fetch metric_card.name, project_name, new: {}
end

format :html do
  view :core do
    wrap_with :div, class: "progress-bar-table" do
      card.item_cards.map do |metric|
        next unless metric.type_id == MetricID
        nest card.metric_project_card(metric), view: :progress_bar_row
      end
    end
  end
end
