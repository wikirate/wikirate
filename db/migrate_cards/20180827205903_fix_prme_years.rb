# -*- encoding : utf-8 -*-

class FixPrmeYears < Card::Migration
  def up
    duplicate_list = []
    each_broken_answer_id do |answer_id|
      if (answer = Card.fetch answer_id)
        update_answer_or_track_duplicate answer, duplicate_list
      else
        puts "no card for answer_id: #{answer_id}"
      end
    end
    store_duplicates duplicate_list
  end

  def update_answer_or_track_duplicate answer, duplicate_list
    new_name = answer.name.gsub /7$/, "6"
    if Card[new_name]
      duplicate_list << answer.name
    else
      answer.update_attributes! name: new_name
    end
  end

  def store_duplicates duplicates
    return if duplicates.empty?
    Card.create name: "PRME duplicates", type_id: Card::PointerID, content: duplicates
  end

  def each_broken_answer_id
    path = File.expand_path "../csv/gri_data_to_clean.csv", __FILE__
    csv = File.read path
    rows = CSV.parse csv
    rows.each { |row| yield row.first.to_i }
  end
end
