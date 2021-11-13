include_set Abstract::Relationship

delegate :value_type, :value_type_code, :value_type_id,
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
