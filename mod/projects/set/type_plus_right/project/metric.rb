# These Project+Metric (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::ProjectScope
include_set Abstract::IdPointer

format :html do
  def input_type
    :filtered_list
  end

  def default_item_view
    :thumbnail_no_link
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  before :menued do
    voo.edit = :inline
    voo.items.delete :view # reset tab_nest
  end

  view :core do
    card.all_item_project_cards.map do |metric_project|
      nest metric_project, view: :bar, hide: %i[project_header bar_nav]
    end
  end
end
