# the following is WIP code developed for the single-use script fashion_merge.rb.
# It is not ready for primetime.

def merge_into target_company
  move_all_answers_to target_company
  # delete!
end

def move_all_answers_to target_company
  researched_answers.each do |answer|
    next unless answer.real?
    target_company = Card.cardish(target_company).name
    target_name = Card::Name[answer.metric.to_s, target_company, answer.year.to_s]
    move_answer answer.card, target_name
  end
end

def move_answer old_answer, new_answer_name
  return duplicate_answer!(new_answer_name) if Card.exists? new_answer_name
  puts "renaming #{old_answer.name} to #{new_answer_name}"
  old_answer.update! name: new_answer_name, update_referers: true, silent_change: true
rescue
  puts "RENAME FAILURE: #{old_answer.name}"
end

def duplicate_answer! answer_name
  puts "DUPLICATE: #{answer_name}"
end
