def refresh_metric_answer_lookup_entry metric_answer_id
  ActManager.act_card
            .act_based_refresh_of_metric_answer_lookup_entry metric_answer_id
end

def act_based_refresh_of_metric_answer_lookup_entry
  @updated_metric_answers ||= ::Set.new
  return if @updated_metric_answers.include? metric_answer_id
  MetricAnswer.find_by_metric_answer_id metric_answer_id
  @updated_metric_answers << metric_answer_id
end
