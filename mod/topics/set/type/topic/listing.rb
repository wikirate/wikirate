include_set Abstract::LazyTree

format :html do
  view :icon_badge, template: :haml
  view :name_badge, template: :haml
  view :bar_left, template: :haml

  view :bar_middle do
    result_middle { count_badges :research_group, :dataset }
  end

  view :bar_right do
    [count_badge(:metric), render_bookmark]
  end

  view :bar_bottom do
    [render_bar_middle, render_details_tab_right, render_details_tab_left]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :dataset
  end

  view :category_name_badge do
    nest_family :name_badge
  end

  view :category_icon_badge do
    nest_family :icon_badge
  end

  view :tree_item do
    if card.subtopic_card.count.positive?
      tree_item render_title, body: render_tree_body, data: { treeval: card.name }
    else
      render_tree_leaf
    end
  end

  view :tree_body do
    field_nest :subtopic, view: :core, items: { view: :tree_item }
  end

  view :tree_leaf do
    content_tag :div, class: "tree-leaf", data: { treeval: card.name } do
      render_title
    end
  end

  private

  def nest_family view
    return "" unless card.topic_families?

    nest card.topic_family, view: view
  end
end
