card_accessor :unknown

UNKNOWN = "Unknown".freeze

event :update_answer_lookup_table_due_to_value_change, :finalize do
  answer_id = left ? left.id : director.parent.card.id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
  refresh_answer_lookup_entry answer_id
end

event :mark_as_imported, before: :finalize_action do
  return unless ActManager.act_card.type_id == MetricValueImportFileID
  @current_action.comment = "imported"
end

event :unknown_value, :prepare_to_validate do
  self.content = UNKNOWN if unknown_card.checked?
  remove_subfield :unknown
end

def value_unknown?
  content == UNKNOWN
end

format :html do
  view :editor do
    super() if metric_card && metric_card.value_type == "Free Text"
    text_field(:content, class: "card-content short-input") + " " +
      nest(card.metric_card, view: :legend)
  end

  view :edit_in_form, cache: :never, perms: :update, tags: :unknown_ok do
    super() + unknown_checkbox + check_request_checkbox
  end

  def unknown_checkbox
    field = card.attach_subfield :unknown
    field.content = card.value_unknown? ? "1" : "0"
    nest field, hide: :title, view: :edit_in_form
  end

  def check_request_checkbox
    nest card.left.fetch(trait: :checked_by),
         hide: :title, view: :edit_in_form
  end
end
