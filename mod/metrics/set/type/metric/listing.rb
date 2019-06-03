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
            render_question]
  end

  view :box_top do
    render :thumbnail
  end

  view :box_middle do
    render :question
  end

  view :box_bottom do
    count_badges :metric_answer, :wikirate_company
  end

  view :selected_option, template: :haml
end
