include_set Abstract::CompanyField

event :standardize_jurisdiction_codes, :prepare_to_validate do
  return if oc_code
  oc_code_from_content = first_name.sub(/^:/, "")
  return unless (r_name = Card::Region.region_name_for_oc_code(oc_code_from_content))
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


format :json do
  view :core do
    card.first_name
  end
end
