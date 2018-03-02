require_relative "open_corporates_csv_row"

class OpenCorporatesCSVRowOnlyHeadquarters< OpenCorporatesCSVRow
  @columns = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number, :company_name]
  @required = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number]

  def inc_jurisdiction_code
    nil
  end
end
