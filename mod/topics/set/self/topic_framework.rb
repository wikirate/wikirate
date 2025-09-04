def other_frameworks
  Card.search type: :topic_framework,
              not: { id: Card::Set::Self::Topic.featured_framework.card_id }
end

format :html do
  view :framework_tree, cache: :force, template: :haml
end