# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Card.search type: "Metric Title", not: { left_plus: [{}, { type: "Metric" }] } do |title|
  title_card = Card[title]

  if title_card.children.present?
    puts "title card still has children: #{title_card.children.map(&:name) * ', *'}"
  else
    title_card.delete!
  end
end
