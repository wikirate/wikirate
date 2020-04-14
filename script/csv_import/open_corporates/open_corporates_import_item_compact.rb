require_relative "open_corporates_import_item"

# import OC mappings (compact form)
class OpenCorporatesImportItemCompact < OpenCorporatesImportItem
  @columns =
    [:oc_jurisdiction_code, :oc_company_number, :inc_jurisdiction_code,
     :wikirate_number, :company_name]
  @required = [:oc_jurisdiction_code, :oc_company_number, :wikirate_number]
end
