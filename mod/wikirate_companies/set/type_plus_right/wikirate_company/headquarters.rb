include_set Abstract::CompanyField

event :standardize_jurisdiction_codes, :prepare_to_validate do
  return if oc_code # already standardized

  region_name = Card::Region.region_name_for_oc_code oc_code_from_content
  self.content = region_name if region_name
end

def oc_code_from_content
  first_name.sub(/^:/, "")
end

def oc_code
  region = known_item_cards.first
  region.oc_code if region&.type_id == RegionID
end

def metric_code
  :core_headquarters_location
end

format :json do
  view :core do
    card.first_name
  end
end
