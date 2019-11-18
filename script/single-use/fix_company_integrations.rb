require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

def validated_wpfield company
  company.fetch(trait: :wikipedia, new: {})
  wpfield.validate_and_normalize_wikipedia_title
end

Card.where(type_id: Card::WikirateCompanyID).find_each do |company|
  wpfield = validated_wpfield company
  next if wpfield.content.blank?
  if wpfield.errors.any?
    puts "! DELETING: #{company.name} (#{wpfield.content})\n  #{wpfield.errors.messages})"
    # wpfield.delete!
  elsif wpfield.db_content_changed?
    puts "->UPDATING: #{company.name} (#{wpfield.content})"
    # wpfield.save!
  end
end
