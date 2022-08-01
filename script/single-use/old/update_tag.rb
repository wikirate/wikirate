#!/usr/bin/env ruby

# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.as_bot

Card.search(right: "tag", left: { type_id: Card::ClaimID }).each do |card|
  tag_inside = card.item_names
  tag_inside.each do |tag|
    next if Card.exists? tag
    begin
      Card.create! type_id: Card::WikirateTagID, name: tag
    rescue
      puts "invalid tag name: #{tag} FROM #{card.name}"
    end
  end
end
