# the following is WIP code developed for the single-use script fashion_merge.rb.
# It is not ready for primetime.

def merge_into target_company
  move_all_answers_to target_company
  # delete!
end

def move_all_answers_to target_company
  all_answers.each do |answer|
    next unless answer.real?
    answer.move company: target_company
  end
end
