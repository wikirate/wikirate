format :html do
  view :bar_left do
    render :thumbnail_with_vote
  end

  view :bar_right do
    count_badge :wikirate_company
  end

  view :bar_middle do
    count_badges :source, :project
  end

  view :bar_bottom do
    add_name_context
    output [render_bar_middle,
            field_nest(:wikirate_topic, view: :content, items: { view: :link }),
            render_metric_question]
  end

  view :box_top, template: :haml

  view :box_middle, template: :haml

  view :box_bottom, template: :haml
end