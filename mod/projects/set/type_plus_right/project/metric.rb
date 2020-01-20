# These Project+Metric (type plus right) cards refer to the list of
# all companies on a given project.

include_set Abstract::ProjectScope
include_set Abstract::ProjectFilteredList
include_set Abstract::IdPointer

format :html do
  view :core do
    card.count > 50 ? super() : unfiltered_pointer
  end

  def unfiltered_pointer
    card.all_item_project_cards.map do |metric_project|
      nest metric_project, view: :bar, hide: %i[project_header bar_nav]
    end
  end
end
