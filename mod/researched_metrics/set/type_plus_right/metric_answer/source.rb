include_set Abstract::MetricChild, generation: 3
include_set Abstract::DesignerPermissions

event :validate_and_normalize_sources, :prepare_to_validate,
      on: :save, changed: :content do
  errors.add "sources required" if item_names.blank? && required_field?
  annotate_sources
end

# when an answer cites a source, make sure
#   1. the source's +company has the answer's company
#   2. the source's +report_type has the answer's metric's report type
def annotate_sources
  item_names.each do |source_name|
    with_valid_source source_name do |source_card|
      add_report_type source_card
      add_company source_card
    end
  end
end

def required_field?
  left&.source_required?
end

def with_valid_source source_name
  source_card = Card[source_name]
  if source_card&.type_id == SourceID
    yield source_card
  else
    errors.add :item, "No such source exists: #{source_name}"
  end
end

def add_report_type source_card
  report_types = left&.report_type&.item_names
  add_trait_to_source source_card, :report_type, report_types if report_types.present?
end

def add_company source_card
  add_trait_to_source source_card, :wikirate_company, left.company_name
end

def add_trait_to_source source_card, trait, values
  trait_card = source_card.fetch trait: trait, new: {}
  Array.wrap(values).each { |val| trait_card.add_item val }
  add_subcard trait_card
end
