# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Card.where("name like '%\\\\+%' and left_id is null and trash is false")
    .pluck(:id).each do |id|
  card = Card[id]
  next unless card.name.compound?  # some have special + character
  card.name = card.name # this fixes name and left_id/right_id
  msg = "#{card.name}: L#{card.left_id}, R#{card.right_id}"
  if card.left_id == -1 || Card.where(left_id: card.left_id, right_id: card.right_id).take
    puts "DELETE #{msg}"
    card.update_column :trash, true
  else
    puts "UPDATE #{msg}"
    card.update_columns left_id: card.left_id,
                        right_id: card.right_id,
                        name: nil,
                        key: nil
  end
end

Cardio::Utils.empty_trash

puts "done."
