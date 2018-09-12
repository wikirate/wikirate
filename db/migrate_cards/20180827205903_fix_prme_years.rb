# -*- encoding : utf-8 -*-

class FixPrmeYears < Card::Migration
  def up
    repair_answers_without_latest
    conflicts = []
    each_broken_answer_id do |answer_id|
      if (answer = Card.fetch answer_id)
        update_answer_or_track_duplicate answer, conflicts
      else
        # puts "no card for answer_id: #{answer_id}"
      end
    end
    track_conflicts conflicts
  end

  def repair_answers_without_latest
    # not the most efficient way (unless measured in dev time!)
    Answer.where(latest: false).find_each &:latest_to_true
  end

  def update_answer_or_track_duplicate answer, conflicts
    new_name = answer.name.gsub /7$/, "6"
    if (duplicate = Card[new_name])
      handle_duplicate duplicate, answer, conflicts
    else
      answer.update_attributes! name: new_name
    end
  end
  
  def handle_duplicate duplicate, answer, conflicts
    if duplicate.value == answer.value
      # newer answer is exact duplicate
      answer.delete!
    else
      # inexact duplicate. save so we can compare
      conflicts << answer.name
    end
  end

  def track_conflicts conflicts
    return if conflicts.empty?
    Card.create name: "PRME conflicts", type_id: Card::PointerID, content: conflicts
  end

  def each_broken_answer_id
    path = File.expand_path "../csv/gri_data_to_clean.csv", __FILE__
    csv = File.read path
    rows = CSV.parse csv
    rows.each { |row| yield row.first.to_i }
  end
end
