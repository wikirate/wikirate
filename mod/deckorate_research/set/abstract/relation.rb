include_set Abstract::Researched

def relation?
  true
end

def researched?
  true
end

# def researchable?
#   false
# end

def simple_value_type_code
  :number
end

def inverse_card
  Card[inverse]
end

def inverse
  fetch(:inverse)&.first_name
end

# title only (not sure this is real)
def inverse_title
  Card.fetch([metric_title, :inverse])&.first_name
end

# @return [Relationship::ActiveRecord_Relation]
def relationships args={}
  args[:metric_id] = relationship_lookup_id
  ::Relationship.where args
end

# @return [Hash] keys are subject company ids,
#   values are lists of object company ids
def related_companies_hash args={}
  normalize_company_arg company_id_field, args
  relationships(args).each_with_object({}) do |rel, hash|
    key = rel.send company_id_field
    hash[key] ||= []
    hash[key] << rel.send(inverse_company_id_field)
  end
end

# @return [Array<Integer>]
def inverse_company_ids args={}
  normalize_company_arg company_id_field, args
  relationships(args).distinct.pluck inverse_company_id_field
end

# @return [Array] of Cards
def inverse_companies args={}
  inverse_company_ids(args).map { |id| Card[id] }
end

format do
  view :legend do
    wrap_legend { "related companies" }
  end
end

format :html do
  def inverse_property title
    wrap :div, class: "row inverse-property" do
      labeled title, nest(card.inverse_card, view: :thumbnail)
    end
  end
end
