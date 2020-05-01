include_set Abstract::Researched

def relationship?
  true
end

def simple_value_type_code
  :number
end

def inverse_card
  fetch(:inverse).first_card
end

def inverse
  fetch(:inverse).first_name
end

def inverse_title
  Card.fetch([metric_title, :inverse])&.first_name
end

# @return [Relationship::ActiveRecord_Relation]
def relationships args={}
  args[:metric_id] = id
  Relationship.where args
end

# @return [Array] of Integers
def inverse_company_ids args={}
  normalize_company_arg inverse_company_id_field, args
  relationships(args).distinct.pluck inverse_company_id_field
end

# @return [Array] of Cards
def inverse_companies args={}
  inverse_company_ids(args).map { |id| Card[id] }
end

format :html do
  def value_legend _html=true
    "related companies"
  end
end
