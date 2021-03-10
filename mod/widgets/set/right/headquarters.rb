
event :transform_jurisdiction_codes, :prepare_to_validate do
  return if oc_code
  oc_code_from_content = first_name.sub(/^:/, "")
  return unless (r_name = Set::Right::OcJurisdictionKey.region_name(oc_code_from_content))
  self.content = "[[#{r_name}]]"
end

event :validate_jurisdiction_code, :validate do
  errors.add :content, "invalid headquarters: #{content}" unless oc_code
end

# if we're assuming left is a company, this should arguably be in a type_plus_right set
def needs_oc_mapping?
  (l = left) && l.open_corporates.blank?
end

event :update_oc_mapping_due_to_headquarters_entry, :integrate,
      on: :save, when: :needs_oc_mapping?, skip: :allowed do
  prefixed_oc_code = oc_code.start_with?("oc_") ? oc_code : "oc_#{oc_code}"
  oc = ::OpenCorporates::MappingApi
       .fetch_oc_company_number company_name: name.left,
                                jurisdiction_code: prefixed_oc_code
  return unless oc&.company_number.present?

  region_name =
    Set::Right::OcJurisdictionKey.region_name(oc.incorporation_jurisdiction_code)
  add_subcard name.left_name.field(:open_corporates),
              content: oc.company_number, type: :phrase
  add_subcard name.left_name.field(:incorporation),
              content: region_name,
              type: :pointer
end

def oc_code
  jur = known_item_cards.first
  return unless jur&.type_id == Card::RegionID
  jur.oc_code
end

format :json do
  view :core do
    card.first_name
  end
end
