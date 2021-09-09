format :html do
  view :bar_left do
    render :thumbnail_with_bookmark
  end

  view :bar_right do
    count_badges :wikirate_company, :metric_answer
  end

  view :bar_middle do
    count_badges :source, :dataset
  end

  view :bar_bottom do
    render_details_tab
  end

  view :box_top, template: :haml

  view :box_middle do
    render :question
  end

  view :box_bottom do
    count_badges :metric_answer, :wikirate_company
  end

  view :research_option_header, template: :haml

  view :research_option, template: :haml

  def social_description_card
    card.about_card
  end
end
