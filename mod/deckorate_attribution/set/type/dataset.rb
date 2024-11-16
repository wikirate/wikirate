include_set Abstract::Attributable

#   def attribution_authors
#     organizer_card.item_names
#   end

def each_reference_dump_row &block
  RecordQuery.new(dataset: name).lookup_query.in_batches do |records|
    records.each { |record| record.each_reference_dump_row(&block) }
  end
end
