# note: most code shared across all +value cards is in Abstract::Value.
# However, that module is included in each Cardtype (eg CategoryValue), because
# if it were in the right sets, it would override the type-specific code.

# The following code, by contrast, must be here to ensure that the +value cards get
# the correct cardtype in the first place.

event :ensure_correct_value_type, :initialize, on: :save, when: :typed_value? do
  return unless (correct_type_code = type_code_from_metric)
  return true if type_code == correct_type_code
  self.type_id = Card.id correct_type_code
  skip_event! :validate_renaming # prevents error from changing type on renaming
                                 # however, this should eventually be removable
                                 # if/when all +value cards have the right value type
  reset_patterns
end

event :validate_answer_value_type, :validate, on: :save, when: :typed_value? do
  errors.add :type, "not a valid +value card" unless type_code.match?(/value$/)
end

# for override
def typed_value?
  false
end
