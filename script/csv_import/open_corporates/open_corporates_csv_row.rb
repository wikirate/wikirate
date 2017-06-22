require_relative "../csv_row"

class OpenCorporatesCSVRow < CSVRow
  @columns =
    [:wikirate_id, :wikirate_company_name, :oc_company_number, :country,
     :headquarters_state, :state_of_incorporation]

  @required = :all

  def validate_wikirate_id value
    (@company = Card[value]) && @company.type_id == Card::WikirateCompanyID
  end

  def validate_headquarters_jurisdiction_code value
    validate_jurisdiction value
  end

  def validate_incorporation_jurisdiction_code value
    validate_jurisdiction value
  end

  def validate_jurisdiction value
    (jc = Card[value.to_sym]) && jc.type_id == Card::JurisdictionID
  end

  def import
    ensure_card [@company, :open_corporates],
                content: oc_company_number,
                type: :phrase
    ensure_card [@company, :headquarters],
                content: Card[headquarters_jurisdiction_code].name,
                type: :pointer
    ensure_card [@company, :incorporation],
                content: Card[incorporation_jurisdiction_code].name,
                type: :pointer
  end
end
