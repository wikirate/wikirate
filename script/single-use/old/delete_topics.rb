# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"
require "csv"

FILENAME = File.expand_path "../data/topics_to_delete.csv", __FILE__

# include Card::Model::SaveHelper

def csv
  CSV.new raw, headers: true
end

def raw
  File.read FILENAME
end

def fetch id
  Card.fetch id.to_i
end

puts "deleting obsolete fields"

["all metrics", "all companies", "*vote count", "*upvote count",
 "*downvote count", "right sidebar", "metric count"].each do |tag|
  Card.search(left: { right: tag }).each(&:delete!)
  Card.where(right_id: tag.card_id).in_batches.update_all trash: true
end

puts "cleaning up trash"

Card::Cache.reset_all
Cardio::Utils.empty_trash

csv.each do |r|
  next unless (t = fetch r["id"])

  puts "deleting #{t.id}: #{t.name}"

  t.delete!
  # t.each_child do |child|
  #   puts "  CHILD: #{child.name}"
  # end
  # Card.search(refer_to: t.id,
  #             left: { not: { type: :source } },
  #             return: :name) do |referer|
  #   puts "  REFERER: #{referer}"
  # end
end

puts "done"
