include_set Abstract::CompanyField

event :standardize_jurisdiction_codes, :prepare_to_validate do
  return if oc_code
  oc_code_from_content = first_name.sub(/^:/, "")
  return unless (r_name = ::OpenCorporates::RegionCache.region_name(oc_code_from_content))
  self.content = "[[#{r_name}]]"
end

def oc_code
  jur = known_item_cards.first
  expected_type_id =
    Card::Codename.exist?(:region) ? Card::RegionID : Card::JurisdictionID
  return unless jur&.type_id == expected_type_id
  jur.oc_code
end

def metric_code
  :core_headquarters_location
end

# event :validate_jurisdiction_code, :validate do
#   errors.add :content, "invalid headquarters: #{content}" unless oc_code
# end

# Not doing mapping for now
# We realized the old CERTH server was not actually handling these requests any more.

# def needs_oc_mapping?
#   (l = left) && l.open_corporates.blank?
# end
# event :update_oc_mapping_due_to_headquarters_entry, :integrate,
#       on: :save, when: :needs_oc_mapping?, skip: :allowed do
#
#   prefixed_oc_code = oc_code.start_with?("oc_") ? oc_code : "oc_#{oc_code}"
#   oc = ::OpenCorporates::MappingApi
#        .fetch_oc_company_number company_name: name.left,
#                                 jurisdiction_code: prefixed_oc_code
#   return unless oc&.company_number.present?
#
#   region_name =
#     ::OpenCorporates::RegionCache.region_name(oc.incorporation_jurisdiction_code)
#   add_subcard name.left_name.field(:open_corporates),
#               content: oc.company_number, type: :phrase
#   add_subcard name.left_name.field(:incorporation),
#               content: region_name,
#               type: :pointer
# end

format :json do
  view :core do
    card.first_name
  end
end
