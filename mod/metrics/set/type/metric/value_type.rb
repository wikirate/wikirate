# VALUE TYPES

# Currently we have a slightly redundant value type system.
#
# For any given type, there is a card (with a codename) for both
# (a) short name: the value type as it appears to users, eg Number(:number), and
# (b) long name: the cardtype card, eg NumberValue(:number_value)
#
# These could and should clearly be unified.

# Value Type, short name:
# ~~~~

# @return String
def value_type
  value_type_card&.first_name || default_value_type_code.cardname
end

# @return Symbol
def value_type_code
  value_type_card&.first_code || default_value_type_code
end

# @return Symbol
def default_value_type_code
  calculated? ? :number : :free_text
end

# Overwritten in Abstract::Relationship
# In relationship metrics, the value_type setting configures the value type of
# relationship answer value (M+C+Y+C+v), *not* the value type of the simple answer
# (M+C+Y+v). This method is specifically for simple answers.
# @return Symbol
def simple_value_type_code
  value_type_code
end

# Value Type, long name:
# ~~~~
# @return Symbol
def value_cardtype_code
  :"#{value_type_code}_value"
end

# @return Symbol
def simple_value_cardtype_code
  :"#{simple_value_type_code}_value"
end

# @return Integer
def value_cardtype_id
  Card::Codename.id value_cardtype_code
end

def numeric?
  ten_scale? || value_type_code.in?(%i[number money])
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type_code.in? %i[category multi_category]
end

def multi_categorical?
  value_type_code == :multi_category
end
