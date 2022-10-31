
# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

REF_MAP = {
  Answer => %i[answer_id metric_id company_id creator_id editor_id],
  Relationship => %i[relationship_id metric_id subject_company_id object_company_id
                     answer_id inverse_answer_id inverse_metric_id]
}.freeze

def bad_referers klass, field
  klass.where "#{field} is not null and not exists " \
               "(select * from cards where cards.id = #{field} and trash is false)"
end

def missing_lookups type_id, table, field
  Card.where(
    "type_id = #{type_id} and trash is false and not exists " \
    "(select * from #{table} where #{field} = cards.id)"
  ).pluck(:id).each do |id|
    yield Card[id]
  end
end

def missing_values type_id
  Card.where(
    "type_id = #{type_id} and trash is false and not exists " \
    "(select * from cards c2 where c2.left_id = cards.id " \
    "and c2.trash is false and c2.right_id = #{Card::ValueID})"
  ).pluck(:id).each do |id|
    yield Card[id]
  end
end

puts "BAD FOREIGN KEYS"
# DELETE lookups with bad foreign keys (references to cards that don't exist)
REF_MAP.each do |klass, field_list|
  field_list.each do |field|
    puts "\n\n WORKING ON #{field}"

    bad_referers(klass, field).each do |item|
      puts "destroy #{item.id}"
      # puts "#{item.metric_type_id.cardname}: #{answer_name answer}"
      item.destroy!
    end
  end
end

puts "DELETE ANSWERS WITHOUT VALUES"
missing_values Card::MetricAnswerID do |unvalued|
  puts "No value card: #{unvalued.name}"
  if unvalued.relationship?
    unvalued.update_relationship_count
  else
    unvalued.delete!
  end
end

puts "DELETE RELATIONSHIPS WITHOUT VALUES"
missing_values Card::RelationshipAnswerID do |unvalued|
  puts "No value card: #{unvalued.name}"
  unvalued.delete!
end

puts "REFRESH answers missing lookups"
missing_lookups Card::MetricAnswerID, :answers, :answer_id do |c|
  puts "#{c.name} does not have an answer"
  c.answer.refresh
end

puts "REFRESH relationships missing lookups"
missing_lookups Card::RelationshipID, :relationships, :relationship_id do |c|
  puts "#{c.name} does not have a relationship"
  c.relationship.refresh
end
