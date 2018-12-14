require_relative "../../config/environment"

def search_args
  type, limit = ARGV
  return { type_id: Card::FileID } unless type
  unless type.in? %w[file image]
    raise ArgumentError, "not a valid file type. pass 'file' or 'image'"
  end
  hash = { type_id: Card.fetch_id(type.to_sym) }
  hash[:limit] = limit.to_i if limit
  hash
end

Card::Auth.as_bot do
  Card.search(search_args).each do |card|
    next if card.cloud?
    puts card.name
    begin
      card.update! storage_type: :cloud, # bucket: aws_bucket,
                              silent_change: true
    rescue ActiveRecord::RecordInvalid => e
      puts e.message
    end
  end
end
