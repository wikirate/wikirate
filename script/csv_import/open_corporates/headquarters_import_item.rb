require_relative "../../../mod/csv_import/lib/import_item.rb"
require_relative "../../../mod/csv_import/lib/csv_file.rb"

class HeadquartersImportItem < ImportItem
  @columns = [:wikirate_number, :oc_jurisdiction_code]
  @required = [:oc_jurisdiction_code, :wikirate_number]

  def normalize_oc_jurisdiction_code value
    "oc_#{value}".to_sym
  end

  def validate_wikirate_number value
    value.number? && (@company = Card[value.to_i]) &&
      @company.type_id == Card::WikirateCompanyID
  end

  def validate_oc_jurisdiction_code value
    validate_jurisdiction value
  end

  def validate_jurisdiction value
    (jc = Card[value]) && jc.type_id == Card::JurisdictionID
  end

  def import_headquarters
    ensure_card [@company, :headquarters],
                content: Card[oc_jurisdiction_code].name,
                type: :pointer,
                skip_event: :update_oc_mapping_due_to_headquarters_entry
  end

  def import
    import_headquarters
  end
end