include_set Abstract::Attributable

#   def attribution_authors
#     organizer_card.item_names
#   end

def each_reference_dump_row &block
  AnswerQuery.new(dataset: name).lookup_query.in_batches do |answers|
    answers.each { |answer| answer.each_reference_dump_row(&block) }
  end
end
