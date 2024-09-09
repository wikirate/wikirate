require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Card::Count.where("EXISTS (SELECT * from card_counts c2 " \
            "WHERE c2.left_id = card_counts.left_id " \
            "AND c2.right_id = card_counts.right_id " \
            "AND card_counts.id < c2.id)").each do |count|
  puts "duplicate count for #{count.left_id.cardname}+#{count.right_id.cardname}"
  count.destroy!
end
