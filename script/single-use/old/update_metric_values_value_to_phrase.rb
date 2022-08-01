# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path("../../config/environment",  __FILE__)

Card::Auth.as_bot do
  value_in_basic_type = Card.search(left: { type_id: Card::MetricAnswerID }, right: { name: "value", type_id: Card::BasicID })
  value_in_basic_type.each do |card|
    puts card.name
    card.update_column(:type_id, Card::PhraseID)
  end
end
