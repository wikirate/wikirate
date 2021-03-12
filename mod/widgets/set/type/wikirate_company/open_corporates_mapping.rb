# event :oc_mapping, :integrate, on: :create, when: :has_mapping_data? do
#   opts = if wikipedia.present?
#            { wikipedia_url: wikipedia }
#          else
#            { company_name: name,
#              jurisdiction_code: headquarters_jurisdiction_code }
#          end
#   oc = ::OpenCorporates::MappingApi.fetch_oc_company_number opts
#   return unless oc.company_number.present?
#
#   add_subfield :open_corporates, content: oc.company_number, type: :phrase
#   add_subfield :incorporation,
#             content: ::OpenCorporates::RegionCache(oc.incorporation_jurisdiction_code),
#             type: :pointer
# end
#
# def has_mapping_data?
#   wikipedia.present? || headquarters_jurisdiction_code.present?
# end
