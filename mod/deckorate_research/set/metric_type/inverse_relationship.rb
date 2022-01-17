include_set Abstract::Relationship

DEPENDENT_PROPERTIES =
  %i[wikirate_topic value_type unpublished year company_group research_policy
  report_type steward about methodology unit range value_options].freeze

delegate *(DEPENDENT_PROPERTIES + [{ to: :inverse_card }])
delegate *(DEPENDENT_PROPERTIES.map { |dp| "#{dp}_card" } + [{ to: :inverse_card }])

delegate :value_type_code, :value_type_id,
         :value_cardtype_code, :value_cardtype_id, to: :inverse_card

# OVERRIDES
def inverse?
  true
end

# lookup field for answers in relationship table
def answer_lookup_field
  :inverse_answer_id
end

def metric_lookup_field
  :inverse_metric_id
end

def company_id_field
  :object_company_id
end

# inverse here means "opposite".
# like the inverse of an InverseRelationship is the Relationship
def inverse_company_id_field
  :subject_company_id
end

def relationship_lookup_id
  inverse_card&.id
end

format :html do
  def table_properties
    {
      metric_type: "Metric Type",
      inverse:     "Inverse Metric of"
    }
  end

  def edit_properties
    []
  end

  view :main_details do
    ["<hr/>", nest(card.inverse, view: :details_tab, hide: :relationship_properties)]
  end
end