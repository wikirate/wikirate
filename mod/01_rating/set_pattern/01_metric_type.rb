@@options = {
  :junction_only => true,
  :index         => 3,
  :anchor_parts_count=>1
}

def metric_type card
  #(mm = card.fetch(trait: :metric_type, skip_modules: true, skip_type_lookup: true,  new: {type_id: Card::PointerID}) ||
  (mm = Card.fetch("#{card.name}+*metric type", skip_modules: true,
  new: {type_id: Card::PointerID}) #skip_virtual: true) ||
        card.subfield(:metric_type)) &&
    mm.content.scan(/\[\[([^\]]+)\]\]/).flatten.first
end

def label name
  'metric type'
end


def pattern_applies? card
  card.type_id == Card::MetricID
end


def prototype_args anchor
  { type: 'metric' }
end

def anchor_name card
  Card::MetricTypeSet.metric_type card
end


