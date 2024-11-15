# records that cite this source
include_set Abstract::SearchCachedCount
include_set Abstract::FullRecordSearch
include_set Abstract::Chart

def query_hash
  { source: left_id }
end

# recount records for a given source when a citation is updated
recount_trigger :type_plus_right, :record, :source do |citation|
  record_searches_for_sources citation.item_cards
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  record_searches_for_sources changed_card.left&.source_card&.item_cards
end

# ...or when record is (un)published
field_recount_trigger :type_plus_right, :record, :unpublished do |changed_card|
  record_searches_for_sources changed_card.left&.fetch(:source)&.item_cards
end

def self.record_searches_for_sources sources
  sources.map do |source_card|
    source_card.fetch :record
  end.compact
end

format do
  def record_page_fixed_filters
    { source: "~#{card.left_id}" }
  end
end
