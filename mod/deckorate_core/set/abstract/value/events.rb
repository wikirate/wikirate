event :standardize_unknown_value, :prepare_to_validate do
  self.content = ::Answer::UNKNOWN if ::Answer.unknown? content
end

event :no_empty_value, :validate, on: :save do
  errors.add :content, "empty answers are not allowed" unless content.present?
end

event :no_left_name_change, :prepare_to_validate, on: :update, changed: :name do
  return if @supercard # as part of other changes (probably) ok
  return unless name.right == "value" # ok if not a value anymore
  return if Card[name.left]&.type_id == Card::AnswerID  # or relationship??
  errors.add :name, "not allowed to change. " \
                    "Change #{name_was.to_name.left} instead"
end

# event :check_length, :validate, on: :save, changed: :content do
#   errors.add :value, "too long (not more than 1000 characters)" if value.size >= 1000
# end

event :reset_double_check, :validate, on: :update, changed: :content do
  full_trait_name = name.left_name.field_name :checked_by
  next unless Card.real?(full_trait_name) && !subcard?(full_trait_name)
  subcard full_trait_name, content: ""
end

event :monitor_hybridness, :integrate, on: %i[create delete], when: :calculated? do
  metric_card.calculate_answers company_id: company_id, year: year
end

event :mark_action, before: :finalize_action, changed: :content do
  action_mark =
    if import_act?
      @current_action.comment = "imported"
    elsif Card::Auth.api_act?
      @current_action.comment = "api"
    end
  @current_action.comment = action_mark if action_mark
end

private

# FIXME: this test would return true for a calculated value card.
# (but is so far only used on new cards, I think)
def overridden_value?
  metric_card.calculated? && left&.answer&.virtual?
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
