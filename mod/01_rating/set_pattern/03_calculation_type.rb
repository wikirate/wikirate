@@options = {
  junction_only: true,
  index:         4,
  anchor_parts_count: 1
}

def label name
  'calculated metrics'
end

def pattern_applies? card
#  return false
  card.type_id == Card::MetricID # &&
 #   (mm = card.fetch(trait: :metric_method, skip_modules: true)) &&
  #  mm.content == 'calculation' &&
  # card.fetch(trait: :calculation_type, skip_modules: true)
end

def prototype_args anchor
  {
    type: 'metric',
    subcards: {"+#{Card[:metric_method]}" => 'calculation' }
  }
end

def anchor_name card
  metric_type = Card::MetricTypeSet.metric_type card
  return if metric_type == Card[:researched].name
  metric_type
end

#card = Card.create! name: 'Designer+MetricName', type_id: Card::MetricID, :subcards=>{'+about'=>'test'}