event :process_sources, :prepare_to_validate,
      on: :save, when: proc { |c| c.researched? } do
  if (sources = subfield(:source))
    sources.item_names.each do |source_name|
      if Card.exists? source_name
        add_report_type source_name
        add_company source_name
      else
        errors.add :source, "#{source_name} does not exist."
      end
    end
  elsif action == :create
    errors.add :source, "does not exist."
  end
end

def source_subcards new_source_card
  [new_source_card.subfield(:file), new_source_card.subfield(:text),
   new_source_card.subfield(:wikirate_link)]
end

def source_in_request?
  sub_source_card = subfield("source")
  return false if sub_source_card.nil? ||
                  sub_source_card.subcard("new_source").nil?
  new_source_card = sub_source_card.subcard("new_source")
  source_subcard_exist?(new_source_card)
end

def source_subcard_exist? new_source_card
  file_card, text_card, link_card = source_subcards new_source_card
  (file_card && file_card.attachment.present?) ||
    (text_card && text_card.content.present?) ||
    (link_card && link_card.content.present?)
end

# TODO: add #subfield_present? method to subcard API
def subfield_exist? field_name
  subfield_card = subfield(field_name)
  !subfield_card.nil? && subfield_card.content.present?
end

def add_report_type source_name
  if report_type
    report_names = report_type.item_names
    source_card = Card.fetch(source_name).fetch trait: :report_type, new: {}
    report_names.each do |report_name|
      source_card.add_item report_name
    end
    add_subcard source_card
  end
end

def add_company source_name
  source_card = Card.fetch(source_name).fetch trait: :wikirate_company, new: {}
  source_card.add_item company_name
  add_subcard source_card
end

def report_type
  metric_card.fetch trait: :report_type
end
