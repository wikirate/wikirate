require_relative "../../config/environment"

# script for fixing junction cards where name doesn't match parts.
# (eg, left_id is A, right_id is B, but name is C+B)

# NOTE: there is nothing wikirate-specific here.

Card::Auth.as_bot

BROKEN_QUERY = "SELECT main.id FROM cards main
                JOIN cards as cleft ON main.left_id = cleft.id
                JOIN cards as cright on main.right_id = cright.id
                WHERE main.`key` <> concat(cleft.`key`, '+', cright.`key`)
                AND main.trash is false"

def fix_card bcard, correct_name
  if Card.exists? correct_name
    bcard.delete!
  else
    bcard.update! name: correct_name, update_referers: true
  end
rescue StandardError => e
  puts %(failed to update #{bcard.name}; #{e.name}\n #{e.backtrace.join "\n"})
end

broken_ids = Card.connection.exec_query(query).rows

broken_ids.each do |id|
  bcard = Card[id.first]
  correct_name = "#{bcard.left_id.cardname}+#{bcard.right_id.cardname}"
  fix_card bcard, correct_name
end
