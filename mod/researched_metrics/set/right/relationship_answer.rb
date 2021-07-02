include_set Abstract::Export
include_set Type::SearchType

delegate :inverse?, to: :metric_card

def virtual?
  true
end

format do
  delegate :inverse?, to: :card

  def search_with_params
    relationship_ids.map(&:card)
  end

  def count_with_params
    @count_with_params ||= relationship_relation.count
  end

  def relationship_ids
    relationship_relation.pluck :relationship_id
  end

  def relationship_relation
    with_relation_paging Relationship.where(relationship_query)
  end

  def with_relation_paging relation
    paging = paging_params
    relation.limit(paging[:limit]).offset(paging[:offset])
  end
end

format :csv do
  view :core do
    Relationship.csv_title + relationships.map(&:csv_line).join
  end

  def default_limit
    nil
  end

  def relationships
    skip_lookup? ? [] : relationship_relation
  end
end
