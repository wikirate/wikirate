# answer that cite this source
include_set Abstract::SearchCachedCount
include_set Abstract::FullAnswerSearch
include_set Abstract::Chart

def query_hash
  { source: left_id }
end

# recount answers for a given source when a citation is updated
recount_trigger :type_plus_right, :answer, :source do |citation|
  answer_searches_for_sources citation.item_cards
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  answer_searches_for_sources changed_card.left&.source_card&.item_cards
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  answer_searches_for_sources changed_card.left&.fetch(:source)&.item_cards
end

def self.answer_searches_for_sources sources
  sources.map do |source_card|
    source_card.fetch :answer
  end.compact
end

format do
  def answer_page_fixed_filters
    { source: "~#{card.left_id}" }
  end
end
