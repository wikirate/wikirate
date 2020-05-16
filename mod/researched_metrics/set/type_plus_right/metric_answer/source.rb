include_set Abstract::MetricChild, generation: 3
include_set Abstract::DesignerPermissions

event :auto_add_source, :prepare_to_validate,
      on: :save, changed: :content, trigger: :required do
  auto_add_url_items
end

event :validate_and_normalize_sources, :validate,
      on: :save, changed: :content do
  errors.add :content, "sources required" if item_names.blank? && required_field?
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

private

def auto_add_url_items
  item_names.each do |item|
    next unless Self::Source.url? item
    source_card = add_source_card item
    drop_item item
    add_item source_card.name
  end
end

def add_source_card url
  Card.create type: SourceID, "+:wikirate_link" => url
  # source_card =
  # source_card.set_autoname
  # add_subcard source_card
  # source_card
end

def with_valid_source source_name
  source_card = Card[source_name]
  if source_card&.type_id == SourceID
    yield source_card
  else
    invalid_source_item source_name
  end
end

def invalid_source_item source_name
  message = if Self::Source.url? source_name
              "Adding urls as sources directly requires event configuration"
            else
              "No such source exists: #{source_name}"
            end
  errors.add :item, message
end

def add_report_type source_card
  return unless (report_types = left&.report_type&.item_names)&.present?
  add_trait_to_source source_card, :report_type, report_types
end

def add_company source_card
  add_trait_to_source source_card, :wikirate_company, left.company_name
end

def add_trait_to_source source_card, trait, values
  trait_card = source_card.fetch trait, new: {}
  Array.wrap(values).each { |val| trait_card.add_item val }
  add_subcard trait_card if trait_card.db_content_changed?
end
