# include with option :generation
# @example including set is grandchild of a metric (eg. name is like metric+a+b)
#   include_set Abstract::MetricChild, generation: 2
def self.included host_class
  host_class.class_eval do
    define_method :generation do
      host_class.generation || 1
    end
  end
end

def metric_part full_name=name
  parts_for_metric(full_name).join Cardname.joint
end

def year_part full_name=name
  full_name.to_name.parts[1 - generation]
end

def company_part full_name=name
  full_name.to_name.parts[-generation]
end

def metric
  metric_part
end

def metric_name
  metric.to_name
end

def metric_id
  metric.card_id
end

def metric_was
  name_was && metric_part(name_was)
end

def metric_card
  # in the integrate phase when updating calculations
  # there can be a superleft without set modules
  (generation == 1 && left&.include_set_modules) || Card.fetch(metric) || nil
  # FIXME: hack to make it work on new cards
end

def metric_type
  metric_card&.metric_type_codename
end

def value_type
  if (value_type_card = Card.fetch "#{metric_card.name}+value type") &&
     !value_type_card.content.empty?
    return value_type_card.item_names[0]
  end
  nil
end

def year
  return unless generation >= 2
  year_part
end

def year_was
  name_was && year_part(name_was)
end

def year_name
  year.to_name
end

def year_card
  Card.fetch year
end

def company
  company_part
end

def company_was
  name_was && company_part(name_was)
end

def company_name
  company.to_name
end

def company_card
  Card.fetch company
end

def company_id
  company.card_id
end

def answer_name
  "#{metric_name}+#{company_name}+#{year}"
end

def record
  record_name.s
end

def record_name
  metric_name.field_name(company)
end

def record_id
  record_name.card_id
end

def record_card
  Card.fetch record
end

def parts_for_metric full_name
  full_name.to_name.parts[0..(-1 - generation)]
end

format do
  delegate :metric_name, :company_name, :record_name, :year_name,
           :metric_card, :company_card, :record_card, :year_card,
           to: :card
end

delegate :value_options, :value_options_card, :numeric?, :categorical?, to: :metric_card

def self.delegate_to_metric_card_if_available *methods
  methods.each do |method|
    define_method(method) { metric_card&.send method }
  end
end

delegate_to_metric_card_if_available :researched?, :calculated?, :hybrid?,
                                     :relationship?, :standard?, :descendant?,
                                     :score?, :ten_scale?, :rating?
