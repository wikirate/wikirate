require File.expand_path("../../config/environment",  __FILE__)

Card::Auth.as_bot do
  Card.search(type: [:in, "file", "image"]).each do |card|
    next if card.cloud?
    card.update_attributes! storage_type: :cloud, bucket: :live_bucket,
                            silent_change: true
  end
end
