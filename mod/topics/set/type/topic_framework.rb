include_set Abstract::LazyTree
include_set Abstract::Stewardable

card_accessor :topic, type: :search_type
card_accessor :category

def featured?
  codename && codename == Self::Topic.featured_framework
end

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
