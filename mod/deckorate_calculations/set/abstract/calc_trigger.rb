# metric fields for which content changes should trigger a recalculation
# (but only once if multiple such fields are editing in one act)

event :schedule_recalculation, :integrate, on: :save, changed: :content do
  metric_card.schedule :recalculate_answers
end
