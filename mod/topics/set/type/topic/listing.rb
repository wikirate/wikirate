include_set Abstract::LazyTree

format :html do
  view :icon_badge, template: :haml, unknown: :blank
  view :name_badge, template: :haml, unknown: :blank
  view :bar_left, template: :haml

  view :bar_middle do
    result_middle { count_badges :research_group, :dataset }
  end

  view :bar_right do
    [count_badge(:metric), render_bookmark]
  end

  view :bar_bottom do
    [render_details_tab_left, render_details_tab_right, ]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :metric, :dataset
  end

  view :category_name_badge, unknown: :blank do
    nest_family :name_badge
  end

  view :category_icon_badge, unknown: :blank do
    nest_family :icon_badge
  end

  view :tree_item do
    add_name_context card.name.left
    voo.joint = " "
    if subtopics?
      tree_item render_title, body: render_tree_body, data: { treeval: "~#{card.id}" }
    else
      render_tree_leaf
    end
  end

  view :tree_body do
    field_nest :subtopic, view: :content, items: { view: :tree_item }
  end

  view :tree_leaf do
    content_tag :div, class: "tree-leaf", data: { treeval: "~#{card.id}" } do
      render_title
    end
  end

  def standard_title
    card.name.right
  end

  def topic_key
    @topic_key ||= card.name.right_key
  end

  private

  def subtopics?
    card.subtopic_card.count.positive?
  end

  def nest_family view
    return "" unless card.topic_families? && (family = card.topic_family).present?

    nest family, view: view
  end
end
