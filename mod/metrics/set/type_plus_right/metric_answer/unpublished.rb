include_set Abstract::LookupField

event :update_calculated_unpublished, :finalize, changed: :content do
  return if lookup_card.action.in? %i[create delete]

  lookup_card.each_depender_answer { |answer| answer.refresh :unpublished }
end
