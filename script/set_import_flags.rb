#!/usr/bin/env ruby

require File.expand_path("../../config/environment", __FILE__)

JOIN_SQL = "LEFT JOIN cards ON cards.id = card_id"
WHERE_SQL = "card_act_id IN (?) AND cards.right_id = ?"

import_card_ids = Card.search type_id: Card::MetricValueImportFileID,
                              return: :id
import_act_ids = Card::Act.where("card_id IN (?)", import_card_ids)
  .pluck(:id)
value_id = Card.fetch_id :value

answer_ids =
  Card::Action.joins(JOIN_SQL)
    .where(WHERE_SQL, import_act_ids, value_id)
    .pluck("cards.left_id")

puts "updating #{answer_ids.size} import actions of "\
     "#{import_card_ids.size} import cards ..."
Card::Action.joins(JOIN_SQL)
  .where(WHERE_SQL, import_act_ids, value_id)
  .update_all(comment: "imported")

answer_ids.uniq!
missing = answer_ids - Answer.pluck(:id)
puts "updating #{answer_ids.size} answers in lookup table ..."
Answer.refresh missing
Answer.where("id IN (?)", uniq_answer_ids).update_all(imported: true)

# Card::Action.find_by_sql(
#   "SELECT `card_actions`.*, COUNT(*) "\FROM `card_actions`" \
#   "LEFT JOIN cards ON cards.id = card_id "\
#   "WHERE (card_act_id IN (#{import_act_ids.join(',')}) "\
#   "       AND cards.right_id = 43591) "\
#   "GROUP BY card_id HAVING COUNT(*) > 1"

