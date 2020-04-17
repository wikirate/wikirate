#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

# updates import flag in action and lookup table entries
class ImportFlagUpdate
  class << self
    JOIN_SQL = "LEFT JOIN cards ON cards.id = card_id".freeze
    WHERE_SQL = "card_act_id IN (?) AND cards.type_id = ?".freeze

    def action_table
      puts "updating #{action_count} import actions of "\
           "#{import_card_ids.size} import cards ..."

      action_relation.update_all(comment: "imported")
    end

    def answer_table
      puts "updating #{answer_ids.size} answers in lookup table ..."

      missing = answer_ids - Answer.pluck(:answer_id)
      # missing.select! { |c| Card.exists? c }

      # puts missing.size.to_s
      # missing.reject { |c| !Card[c].metric_card }
      # puts missing.size.to_s
      Answer.refresh missing
      Answer.where("answer_id IN (?)", answer_ids).update_all(imported: true)
    end

    private

    def action_count
      answer_ids_with_duplicates.size
    end

    def answer_ids
      @answer_ids ||= answer_ids_with_duplicates.uniq
    end

    def answer_ids_with_duplicates
      @answer_ids_with_duplicates ||=
        action_relation.pluck("cards.id")
    end

    def import_card_ids
      @import_card_ids ||= Card.search type_id: Card::AnswerImportID, return: :id
    end

    def import_act_ids
      Card::Act.where("card_id IN (?)", import_card_ids).pluck(:id)
    end

    def action_relation
      Card::Action.joins(JOIN_SQL)
                  .where(WHERE_SQL, import_act_ids, Card::MetricAnswerID)
    end
  end
end

ImportFlagUpdate.action_table
ImportFlagUpdate.answer_table

# Card::Action.find_by_sql(
#   "SELECT `card_actions`.*, COUNT(*) "\FROM `card_actions`" \
#   "LEFT JOIN cards ON cards.id = card_id "\
#   "WHERE (card_act_id IN (#{import_act_ids.join(',')}) "\
#   "       AND cards.right_id = 43591) "\
#   "GROUP BY card_id HAVING COUNT(*) > 1"
