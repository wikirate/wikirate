# has to be called in finalize events so that in integrate stage all changes
# are collected in @updated_meteric_answers and can be executed
def refresh_metric_answer_lookup_entry metric_answer_id
  ActManager.act_card
            .act_based_refresh_of_metric_answer_lookup_entry metric_answer_id
end

def act_based_refresh_of_metric_answer_lookup_entry metric_answer_id
  @updated_metric_answers ||= ::Set.new
  return if @updated_metric_answers.include? metric_answer_id
  MetricAnswer.find_by_metric_answer_id metric_answer_id
  @updated_metric_answers << metric_answer_id
end

event :refresh_updated_metric_answers, :integrate do
  return unless @updated_metric_answers
  MetricAnswer.refresh @updated_metric_answers
end
