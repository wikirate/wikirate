UNKNOWN = "Unknown".freeze

event :unknown_value, :prepare_to_validate, when: :unknown_subfield do
  self.content = UNKNOWN if unknown_subfield.checked?
  detach_subfield :unknown
end

event :no_empty_value, :validate do
  return if content.present?
  errors.add :content, "empty answers are not allowed"
end

event :no_left_name_change, :prepare_to_validate,
      on: :update, changed: :name do
  return if @supercard # as part of other changes (probably) ok
  return unless name.right == "value" # ok if not a value anymore
  return if (metric_answer = Card[name.left]) && metric_answer.type_id == Card::MetricAnswerID
  errors.add :name, "not allowed to change. " \
                    "Change #{name_was.to_name.left} instead"
end

event :check_length, :validate, on: :save, changed: :content do
  errors.add :value, "too long (not more than 1000 characters)" if content.size >= 1000
end

event :reset_double_check_flag, :validate, on: [:update, :delete], changed: :content do
  [:checked_by, :check_requested_by].each do |trait|
    full_trait_name = name.left_name.field_name trait
    next unless Card.real?(full_trait_name) && !subcard(full_trait_name)
    attach_subcard full_trait_name, content: ""
  end
end

event :save_overridden_calculated_value, :prepare_to_store,
      on: :create, changed: :content, when: :overridden_value? do
  add_subcard [name.left, :overridden_value], content: left.answer.value, type: :phrase
end

event :mark_as_imported, before: :finalize_action, when: :import_act? do
  @current_action.comment = "imported"
end

private

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
