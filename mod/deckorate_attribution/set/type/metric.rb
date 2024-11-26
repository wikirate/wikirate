include_set Abstract::Attributable

def attribution_title
  metric_title
end

def attribution_authors
  [metric_designer].tap do |list|
    list << "Wikirate's community" if community_assessed?
  end
end

def each_reference_dump_row &block
  calc = calculated?
  ::Answer.where(metric_id: id).in_batches do |answers|
    answers.each do |answer|
      yield answer
      answer.each_dependee_answer(&block) if calc
    end
  end
end
