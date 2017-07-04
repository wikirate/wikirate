include_set Abstract::MetricChild, generation: 4
include_set Abstract::Value

format :html do
  def edit_fields
    [
      [card, { title: "Answer", editor: :standard }],
      [card.left(new: { type_id: RelationshipAnswerID }).fetch(trait: :checked_by, new: {}), { hide: :title }]
    ]
  end
end
