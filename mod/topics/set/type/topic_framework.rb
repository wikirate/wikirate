include_set Abstract::LazyTree

card_accessor :topic, type: :search_type
card_accessor :category

format :html do
  view :titled_content, template: :haml

  view :bar_right do
    count_badges :topic
  end

  view :tree_item do
    tree_item render_title, body: render_tree_body, data: { treeval: "~#{card.id}" }
  end

  view :tree_body do
    field_nest :category, view: :content, items: { view: :tree_item }
  end
end
