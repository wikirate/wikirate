# -*- encoding : utf-8 -*-

class CorrectRelationshipCounts < Card::Migration
  disable_ddl_transaction!

  def up
    answers = ::Set.new
    Card.where(type_id: Card::RelationshipAnswerID).find_each do |card|
      next if answers.include? card.left_id
      card.include_set_modules
      begin
        puts "updated counts for #{card.name}"
        card.update_counts!
      rescue
        puts "error updating counts for #{card.name}"
      end
      answers << card.left_id
    end
  end
end
