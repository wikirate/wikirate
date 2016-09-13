# include with option :generation
# @example
#   include_set Abstract::MetricChild, generation: 2
#   # means the includer is grandchild (e.g. name is like metric+a+b)

def self.included host_class
  host_class.class_eval do
    define_method :metric_parts do |cardname|
      cardname.parts[0..(-1 - host_class.generation)]
    end
  end
end

def metric
  metric_parts(cardname).join("+")
end

def metric_was
  name_was && metric_parts(name_was.to_name).join("+")
end

def metric_card
  Card.fetch metric
end

def metric_type
  metric_card.metric_type.downcase.to_sym
end

def value_type
  if (value_type_card = Card.fetch "#{metric_card.name}+value type") &&
    !value_type_card.content.empty?
    return value_type_card.item_names[0]
  end
  nil
end

def researched?
  (mc = metric_card) && mc.researched?
end

def scored?
  (mc = metric_card) && mc.scored?
end


def metric_card_before_name_change
  return unless (old_metric_name = metric_was) && old_metric_name.present?
  return unless old_metric_name != metric_name
  Card.fetch old_metric_name
end
