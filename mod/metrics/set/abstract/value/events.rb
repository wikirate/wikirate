UNKNOWN = "Unknown".freeze

event :unknown_value, :initialize, when: :unknown_subfield do
  self.content = UNKNOWN if unknown_subfield.checked?
  detach_subfield :unknown
end

event :no_left_name_change, :prepare_to_validate,
      on: :update, changed: :name do
  return if @supercard # as part of other changes (probably) ok
  return unless name.right == "value" # ok if not a value anymore
  return if (metric_answer = Card[name.left]) && metric_answer.type_id == MetricAnswerID
  errors.add :name, "not allowed to change. " \
                    "Change #{name_was.to_name.left} instead"
end

event :check_length, :validate, on: :save, changed: :content do
  errors.add :value, "too long (not more than 1000 characters)" if content.size >= 1000
end

event :update_double_check_flag, :validate, on: [:update, :delete], changed: :content do
  [:checked_by, :check_requested_by].each do |trait|
    next unless left.fetch trait: trait
    attach_subcard name.left_name.field_name(trait), content: ""
  end
end

event :save_overridden_calculated_value, :prepare_to_store,
      on: :create, changed: :content, when: :overridden_value? do
  add_subcard [name.left, :overridden_value], content: left.answer.value, type: :phrase
end

event :mark_as_imported, before: :finalize_action, when: :import_act? do
  @current_action.comment = "imported"
end

event :update_related_scores, :after_integrate, skip: :allowed do
  ensure_metric(metric_card).each_dependent_score_metric do |metric|
    metric.update_value_for! company: company_id, year: year
  end
end

event :update_related_calculations, :after_integrate, skip: :allowed do
  ensure_metric(metric_card).each_dependent_formula_metric do |metric|
    metric.update_value_for! company: company_id, year: year
  end
end

private

def unknown_subfield
  subfield(:unknown
end

# in some cases, deleting a metric can lead to its scores getting deleted
# and losing their metric modules before a save is finalized.
# This (somewhat hacky) fix is to ensure that such metrics act as metrics.
# A deeper fix would make sure cards don't lose their set properties until
# after finalization.
def ensure_metric metric_card
  sc = metric_card.singleton_class
  sc.include Type::Metric unless sc.include? Type::Metric
  metric_card
end
