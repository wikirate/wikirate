include_set Abstract::Relationship

# OVERRIDES
def inverse?
  true
end

def answer_lookup_field
  :inverse_answer_id
end
