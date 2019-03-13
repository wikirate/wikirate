# These Project+Metric (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::Table

def project_name
  name.left
end

# @return [Array] all of this card's items that refer to a valid metric
def valid_metric_cards
  @valid_metric_cards ||=
    item_cards.select do |metric|
      metric.type_id == MetricID
    end
end

# @return [Array] a list of Metric+Project cards (ltype rtype) that connect
# each of this card's metric items to its project.
def all_metric_project_cards
  valid_metric_cards.map do |metric|
    metric_project_card metric.name
  end
end

# @return [Card] a single Metric+Project card (ltype rtype)
def metric_project_card metric_name
  Card.fetch metric_name, project_name, new: {}
end

format :html do
  def editor
    :filtered_list
  end

  def default_item_view
    :thumbnail
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  view :core do
    card.all_metric_project_cards.map do |metric_project|
      nest metric_project, view: :bar
    end
    # nest Card.fetch(card.name, :project), view: :content, items: { view: :bar }
  end
end
