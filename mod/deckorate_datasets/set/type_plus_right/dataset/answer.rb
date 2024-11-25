include_set Abstract::FullAnswerSearch
include_set Abstract::Chart
include_set Abstract::CachedCount

def dataset_name
  name.left_name
end

def query_hash
  { dataset: dataset_name }
end

# recount datasets when companies/metrics associated with dataset are changed
%i[metric company].each do |field|
  recount_trigger :type_plus_right, :dataset, field, on: :save do |changed_card|
    changed_card.left.answer_card
  end
end

# ...or when answer is changed (created, deleted, renamed)
recount_trigger :type, :answer do |changed_card|
  dataset_answer_cards changed_card
end

# ...or when metric or answer is (un)published
%i[metric answer].each do |type|
  field_recount_trigger :type_plus_right, type, :unpublished do |changed_card|
    dataset_answer_cards changed_card.left
  end
end

private

def self.dataset_answer_cards base
  base.dataset_card.item_cards.each(&:answer_card)
end

format do
  # TODO: make it so we can filter by other datasets
  def filter_map
    filter_map_without_keys super, :dataset
  end
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end
end
