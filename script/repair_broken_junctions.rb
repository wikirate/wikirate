require_relative "../config/environment"

# script for fixing junction cards where name doesn't match parts.
# (eg, left_id is A, right_id is B, but name is C+B)

# NOTE: there is nothing wikirate-specific here.

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

CHILD_MISMATCH_QUERY = "SELECT main.id FROM cards main
                        JOIN cards as cleft ON main.left_id = cleft.id
                        JOIN cards as cright on main.right_id = cright.id
                        WHERE main.`key` <> concat(cleft.`key`, '+', cright.`key`)
                        AND main.trash is false"

def fix_child_mismatch bcard, correct_name
  if Card.exists? correct_name
    bcard.delete!
  else
    bcard.update! name: correct_name, update_referers: true
  end
rescue StandardError => e
  puts %(failed to update #{bcard.name}; #{e.name}\n #{e.backtrace.join "\n"})
end

Card.connection.exec_query(CHILD_MISMATCH_QUERY).rows.each do |id|
  bcard = Card[id.first]
  correct_name = "#{bcard.left_id.cardname}+#{bcard.right_id.cardname}"
  fix_child_mismatch bcard, correct_name
end

%i[left right].each do |side|
  child_missing_query =
    "SELECT name from cards " \
    "WHERE #{side}_id is not null AND trash is false " \
    "and NOT EXISTS (select * from cards c2 where c2.id = cards.#{side}_id);"

  Card.connection.exec_query(child_missing_query).rows.each do |id|
    card = Card[id.first]
    if (id = Card.fetch_id card.name.send side)
      card.update_column :"#{side}_id", id
    else
      card.delete!
    end
  end
end

