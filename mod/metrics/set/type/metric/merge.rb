def move_all_answers_to target_metric
  all_answers.each do |answer|
    next unless answer.real?
    answer.move metric: target_metric
  end
end
