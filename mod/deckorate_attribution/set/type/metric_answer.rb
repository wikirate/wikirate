include_set Abstract::Attributable

def attribution_title
  "#{metric_card.metric_title} (#{company}, #{year})"
end

def each_reference_dump_row &block
  yield answer
  each_dependee_answer(&block)
end
