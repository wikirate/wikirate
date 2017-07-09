require_relative "../csv_row"

class OpenCorporatesCSVRowCompact < OpenCorporatesCSVRow
  @columns =
    [:oc_jurisdiction_code, :oc_company_number, :inc_juristiction_code,
     :wikirate_number, :company_name]
end
