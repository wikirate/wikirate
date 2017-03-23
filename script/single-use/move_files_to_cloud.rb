require_relative "../../config/environment"

def type_id_from_argv
  type = ARGV.pop
  return Card::FileID unless type
  unless type.in? %w(file image)
    raise ArgumentError, "not a valid file type. pass 'file' or 'image'"
  end
  Card.fetch_id type.to_sym
end

Card::Auth.as_bot do
  Card.search(type_id: type_id_from_argv, limit: 10).each do |card|
    next if card.cloud?
    card.update_attributes! storage_type: :cloud, # bucket: aws_bucket,
                            silent_change: true
  end
end


