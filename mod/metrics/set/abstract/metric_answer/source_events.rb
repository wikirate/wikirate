# when an answer cites a source, make sure
#   1. the source's +company has the answer's company
#   2. the source's +report_type has the answer's metric's report type
event :annotate_sources, :prepare_to_validate, on: :save, when: :source_based? do
  if (sources = subfield(:source))
    sources.item_names.each { |source| add_source_traits source }
#  elsif !source_card.item_names.any?
#    errors.add :source, "no source cited"
  end
end

def add_source_traits source_name
  return non_existing_source_error source_name unless Card.exists? source_name
  add_report_type source_name
  add_company source_name
end

def non_existing_source_error source_name
  errors.add :source, "#{source_name} does not exist."
end

def add_report_type source_name
  return unless report_type
  add_trait_to_source source_name, :report_type, report_type.item_names
end

def add_company source_name
  add_trait_to_source source_name, :wikirate_company, company_name
end

def add_trait_to_source source, trait, values
  trait_card = Card.fetch(source).fetch trait: trait, new: {}
  Array.wrap(values).each { |val| trait_card.add_item val }
  add_subcard trait_card
end

def source_based?
  standard? || hybrid?
end
