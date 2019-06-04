# ANSWERS

def researched_answers
  Answer.where(metric_id: id)
end

def answer_ids
  researched_answers.pluck(:id)
end

def answer company, year
  company = Card.fetch_id(company) unless company.is_a? Integer
  Answer.where(metric_id: id, company_id: company, year: year.to_i).take
end

def distinct_values
  researched_answers.select(:value).distinct.pluck(:value)
end

def companies_with_years_and_values
  Answer.search(metric_id: id, return: [:company, :year, :value]).map do |c, y, v|
    [c, y.to_s, v]
  end
end

def random_value_card
  Answer.search(metric_id: id, limit: 1).first
end

def random_valued_company_card
  Answer.search(metric_id: id, return: :company_card, limit: 1).first
end

def metric_answer_cards cached: true
  cached ? Answer.search(metric_id: id) : Card.search(metric_answer_query)
end

def value_cards _opts={}
  Answer.search metric_id: id, return: :value_card
end

def metric_answer_name company, year
  Card::Name[name, Card.fetch_name(company), year.to_s]
end

def metric_answer_query
  { left: { left_id: id }, type_id: MetricAnswerID }
end

def researchable?
  researched? || hybrid?
end

# note: can return True for anonymous user if answer is generally researchable
def user_can_answer?
  return false unless researchable?

  # TODO: add metric designer respresentative logic here
  is_admin = Auth.always_ok?
  is_owner = Auth.current.id == creator&.id
  (is_admin || is_owner) || !designer_assessed?
end

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
  type_from_card = value_type_card.item_names.first
  type_from_card.present? ? type_from_card : default_value_type
end

# @return Symbol
def value_type_code
  value_type_card.item_cards.first&.codename || default_value_type_code
end

# @return String
def default_value_type
  default_value_type_code.cardname
end

# @return Symbol
def default_value_type_code
  calculated? ? :number : :free_text
end

# Value Type, long name:
# ~~~~
# @return Symbol
def value_cardtype_code
  :"#{value_type_code}_value"
end

# @return Integer
def value_cardtype_id
  Card::Codename.id value_cardtype_code
end

def value_options
  value_options_card.item_names
end

def numeric?
  calculated? || value_type_code.in?(%i[number money])
end

# TODO: adapt to Henry's value type API
def categorical?
  value_type_code.in? %i[category multi_category]
end

def multi_categorical?
  value_type_code == :multi_category
end
