require_relative "../csv_row"

class OpenCorporatesCSVRow < CSVRow
  @columns =
    [:oc_jurisdiction_code, :oc_company_number, :wikirate_number, :company_name,
     :country, :headquarters_state, :state_of_inc, :inc_jurisdiction_code,
     :headquarters_address]

  @required = :all

  def validate_wikirate_number value
    (@company = Card[value]) && @company.type_id == Card::WikirateCompanyID
  end

  def validate_oc_jurisdiction_code value
    validate_jurisdiction value
  end

  def validate_inc_jurisdiction_code value
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
                content: Card[oc_jurisdiction_code].name,
                type: :pointer
    ensure_card [@company, :incorporation],
                content: Card[inc_jurisdiction_code].name,
                type: :pointer
  end
end
