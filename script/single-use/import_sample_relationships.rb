

def import!
  import_metrics
  import_metric_answers
end

## IMPORT METRICS

def import_metrics
  each_metric_row do |row|
    ensure_designer row[:designer]
    create_metric row
    create_inverse_metric row
  end
end

def each_metric_row
  #open metrics sheet
  yield row
end

def ensure_designer name
  return if Card[name]
  Card.create! name: name, type_id: Card::ResearchGroupID
end

def create_metric row
  Card.create! name: "#{row[:designer]}+#{row[:title]}",
               type: Card::MetricID,
               subcards: metric_subcards(row)
end

def metric_subcards row
  subs = { "+metric_type" => "Relationship" }
  [:value_type, :options, :unit].each_with_obj(subs)) do |fld, hash|
    next unless row[fld]
    hash["+#{fld}"] = row[fld]
  end
end

def create_inverse_metric row
  Card.create! name: "#{row[:designer]}+#{row[:title]}",
               type: Card::MetricID,
               subcards: { "+metric type" => "Inverse Relationship",
                           "+inverse" => "#{row[:designer]}+#{row[:title]}" }
  create_title_inverse_pointer
end

def create_title_inverse_pointer
  Card.create! name: row[:inverse].to_name.field("inverse"),
               content: row[:title]
  # valuable here?
end

## IMPORT METRIC ANSWERS

def import_metric_answers
  each_metric_answer_row do |row|
    answer_name = ensure_metric_answer row
    source_name = ensure_source row[:source]
    add_relationship_answer row, answer_name, source_name
    ensure_inverse_answer row
  end
end

def ensure_metric_answer row
  answer_name = [:designer, :title, :company_1, :year].map { |f| row[f]} * "+"
  ensure_answer answer_name
  answer_name
end

def ensure_anwer answer_name
  answer = Card.fetch answer_name, new: { type: "Metric Value" }
  answer ? update_metric_answer(answer) : create_metric_answer(answer)
end

def create_metric_answer answer
  answer.subcards = { "+value" => "1" }
  answer.save!
end

def update_metric_answer answer
  value = answer.fetch trait: :value
  value.update_attributes content: (value.content.to_i + 1).to_s
end

def ensure_source source_url
  #TODO!
  # Card.create! type: "Source"...
end

def add_relationship_answer row, answer_name, source
  Card.create name: [answer_name, row[:company_2]].join("+"),
              type: "Relationship Answer",
              content: row[:value],
              subcards: { "+source" => source.name }
end

def ensure_inverse_answer row
  answer_name = [:designer, :inverse, :company_2, :year].map { |f| row[f]} * "+"
  ensure_answer answer_name
end

def each_metric_answer_row
  #open metrics answers sheet
  yield row
end

import!