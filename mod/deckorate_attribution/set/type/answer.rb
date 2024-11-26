include_set Abstract::Attributable

def attribution_title
  "#{metric_card.metric_title} (#{company}, #{year})"
end

def each_reference_dump_row &block
  yield answer
  each_dependee_answer(&block)
end

def attribution_changes_link?
  researched?
end

def attribution_changes_text
  "See changes"
end

def attribution_changes_path _created_at
  { view: :history }
end
