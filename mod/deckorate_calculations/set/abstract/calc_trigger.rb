# metric fields for which content changes should trigger a recalculation
# (but only once if multiple such fields are editing in one act)

event :schedule_recalculation, :integrate, on: :save, changed: :content do
  expire # TODO: add test that fails if this is not here
  # without this, formula updates can break. In such cases
  # when Card::Cache.renew is called in delayed jobs, the old
  # version of the formula is brought up from the cache.

  metric_card.schedule :recalculate_answers
end
