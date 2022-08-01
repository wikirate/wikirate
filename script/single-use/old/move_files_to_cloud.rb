# SPDX-FileCopyrightText: 2022 WikiRate info@wikirate.org
#
# SPDX-License-Identifier: GPL-3.0-or-later

require_relative "../../config/environment"

def search_args
  type, limit = ARGV
  return { type_id: Card::FileID } unless type
  unless type.in? %w[file image]
    raise ArgumentError, "not a valid file type. pass 'file' or 'image'"
  end
  hash = { type_id: type.to_sym.card_id }
  hash[:limit] = limit.to_i if limit
  hash
end

Card::Auth.as_bot do
  Card.search(search_args).each do |card|
    next if card.cloud?
    puts card.name
    begin
      card.update! storage_type: :cloud, silent_change: true # bucket: aws_bucket,
    rescue ActiveRecord::RecordInvalid => e
      puts e.message
    end
  end
end
