@@options = {
  :junction_only => true,
  :index         => 4,
  :anchor_parts_count=>1
}

def label name
  'researched or calculated metrics'
end


def pattern_applies? card
  #return false
  card.type_id == Card::MetricID
  #&& card.fetch(trait: :metric_method, skip_modules: true)
end


def prototype_args anchor
  { type: 'metric' }
end

def anchor_name card
  metric_type = Card::MetricTypeSet.metric_type card
  case metric_type
  when Card[:researched].name then metric_type
  else Card[:calculation].name
  end
end
