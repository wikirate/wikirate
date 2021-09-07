# These Dataset+Metric (type plus right) cards refer to the list of
# all companies on a given dataset.

include_set Abstract::DatasetScope
include_set Abstract::DatasetFilteredList
include_set Abstract::IdPointer

format :html do
  view :core do
    card.count > 50 ? super() : unfiltered_pointer
  end

  def unfiltered_pointer
    card.all_item_dataset_cards.map do |metric_dataset|
      nest metric_dataset, view: :bar, hide: %i[dataset_header bar_nav]
    end
  end
end
