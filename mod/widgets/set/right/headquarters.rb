def needs_oc_mapping?
  (l = left) && l.open_corporates.blank?
end

event :update_oc_mapping_due_to_headquarters_entry, :integrate,
      on: :save, when: :needs_oc_mapping?, optional: true do
  oc = ::OpenCorporates::MappingAPI.fetch_oc_company_number company_name: name.left,
                                                            jurisdiction_code: oc_code
  return unless oc.company_number.present?

  add_subcard name.left_name.field(:open_corporates),
              content: oc.company_number, type: :phrase
  add_subcard name.left_name.field(:incorporation),
              content: jurisdiction_name(oc.incorporation_jurisdiction_code),
              type: :pointer
end

# TODO: reduce duplicated code
def jurisdiction_name oc_code
  oc_code = "oc_#{oc_code}" unless oc_code.to_s.match?(/^oc_/)
  Card.fetch_name oc_code.to_sym
end

def oc_code
  jur = item_cards.first
  return unless jur&.type_id == JurisdictionID
  jur.oc_code
end
