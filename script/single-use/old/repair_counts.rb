# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Count.where("EXISTS (SELECT * from counts c2 " \
            "WHERE c2.left_id = counts.left_id " \
            "AND c2.right_id = counts.right_id " \
            "AND counts.id < c2.id)").each do |count|
  puts "duplicate count for #{count.left_id.cardname}+#{count.right_id.cardname}"
  count.destroy!
end
