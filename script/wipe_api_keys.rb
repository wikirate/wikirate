require File.expand_path "../script_helper.rb", __FILE__

Card.search(right: :api_key) do |card|
  next unless card.accounted

  card.delete!
end
