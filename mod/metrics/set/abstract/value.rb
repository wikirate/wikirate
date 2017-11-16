JOINT = ", "

def value_card
  self
end

def value
  raw_value.join JOINT
end

def raw_value
  item_names context: ""
end

def metric_plus_company
  name.parts[0..-3].join "+"
end

def metric_key
  metric.to_name.key
end

def company_key
  company.to_name.key
end

def metric_plus_company_card
  Card.fetch metric_plus_company
end

def unknown_value?
  content.casecmp("unknown").zero?
end

event :check_length, :validate, on: :save, changed: :content do
  if content.size >= 1000
    errors.add :value, "too long (not more than 1000 characters)"
  end
end

event :mark_as_imported, before: :finalize_action do
  return unless ActManager.act_card.type_id == AnswerImportFileID
  @current_action.comment = "imported"
end

event :update_related_scores, :finalize do
  metric_card.related_scores.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end

event :update_related_calculations, :finalize,
      on: [:create, :update, :delete] do
  metric_card.related_calculations.each do |metric|
    metric.update_value_for! company: company_key, year: year
  end
end

event :update_double_check_flag, :validate, on: [:update, :delete],
                                            changed: :content do
  [:checked_by, :check_requested_by].each do |trait|
    next unless left.fetch trait: trait
    attach_subcard name.left_name.field_name(trait), content: ""
  end
end

event :no_left_name_change, :prepare_to_validate,
      on: :update, changed: :name do
  return if @supercard # as part of other changes (probably) ok
  return unless name.right == "value" # ok if not a value anymore
  return if (metric_value = Card[name.left]) &&
            metric_value.type_id == MetricValueID
  errors.add :name, "not allowed to change. " \
                    "Change #{name_was.to_name.left} instead"
end

format :html do
  view :core do
    card.item_names.join(",")
  end
end
