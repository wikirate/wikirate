
event :check_source, :validate, on: :create do
  source_cards = assemble_source_subfields
  validate_source_subfields source_cards
end

event :import_linked_source, :integrate_with_delay, on: :save, when: :wikirate_link? do
  # in theory, this should be in source_type/wikirate_link.rb, but that was causing
  # problems as detailed here: https://www.pivotaltracker.com/story/show/152409610
  generate_pdf if import? && html_link?
end

private

def assemble_source_subfields
  [:wikirate_link, :file, :text].map do |fieldname|
    subfield fieldname
  end.compact
end

def validate_source_subfields source_cards
  if source_cards.length > 1
    errors.add :source, "Only one type of content is allowed"
  elsif source_cards.empty?
    errors.add :source, "Source content required"
  end
end
