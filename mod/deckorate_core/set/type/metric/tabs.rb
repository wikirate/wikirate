format :html do
  # default tab list (several metric types override)
  def tab_list
    %i[details metric_answer source dataset calculation]
  end

  view :wikirate_topic_tab do
    field_nest :wikirate_topic
  end

  view :metric_answer_tab do
    field_nest :metric_answer, view: :filtered_content
  end

  view :source_tab do
    field_nest :source, view: :filtered_content
  end

  view :details_tab, template: :haml

  # def answer_filtering
  #   filtering(".RIGHT-answer ._compact-filter") do
  #     yield view: :bar, show: :full_page_link, hide: %i[metric_header edit_link]
  #   end
  # end

  view :dataset_tab do
    field_nest :dataset, view: :content
  end
end
