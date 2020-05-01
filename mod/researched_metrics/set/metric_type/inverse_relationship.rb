include_set Abstract::Relationship

# OVERRIDES
def inverse?
  true
end

# lookup field for answers in relationship table
def answer_lookup_field
  :inverse_answer_id
end

# inverse here means "opposite".
# like the inverse of an InverseRelationship is the Relationship
def inverse_company_id_field
  :subject_company_id
end
