
format :json do
  view :atom do
    super().merge designer: card.metric_designer,
                  title: card.metric_title
  end
end

format :csv do
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end
end
