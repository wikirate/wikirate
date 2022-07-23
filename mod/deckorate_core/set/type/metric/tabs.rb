format :html do
  # default tab list (several metric types override)
  def tab_list
    %i[metric_answer calculation dataset details]
  end

  view :wikirate_topic_tab do
    field_nest :wikirate_topic
  end

  view :metric_answer_tab do
    field_nest :metric_answer, view: :filtered_content
  end

  view :details_tab do
    [render_metric_properties, render_main_details]
  end

  view :main_details do
    [nest_about, nest_methodology]
  end

  def nest_about
    field_nest :about, view: :titled
  end

  def nest_methodology
    return unless card.researchable?
    field_nest :methodology, view: :titled
  end

  # def answer_filtering
  #   filtering(".RIGHT-answer ._compact-filter") do
  #     yield view: :bar, show: :full_page_link, hide: %i[metric_header edit_link]
  #   end
  # end

  view :dataset_tab do
    field_nest :dataset, view: :content
  end
end
