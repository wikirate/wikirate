format :html do
  view :bar_left do
    render :thumbnail_with_vote
  end

  view :bar_right do
    count_badges :wikirate_company, :metric_answer
  end

  view :bar_middle do
    count_badges :source, :project
  end

  view :bar_bottom do
    output [render_bar_middle,
            field_nest(:wikirate_topic, view: :content, items: { view: :link }),
            render_metric_question]
  end

  view :box_top, template: :haml

  view :box_middle, template: :haml

  view :box_bottom, template: :haml

  view :selected_option, template: :haml

  bar_cols 7, 5
  info_bar_cols 5, 4, 3
end
