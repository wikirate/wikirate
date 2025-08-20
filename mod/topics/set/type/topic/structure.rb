format :html do
  mini_bar_cols 7, 5

  before :content_formgroups do
    voo.edit_structure = %i[topic_framework category image general_overview]
  end

  def tab_list
    %i[details metric].tap do |list|
      list << :dataset if card.framework_card.featured?
    end
  end

  def tab_options
    { research_group: { label: "Research Groups" } }
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :research_group_tab do
    field_nest :research_group, view: :filtered_content
  end

  view :dataset_tab do
    field_nest :dataset, view: :filtered_content
  end

  view :details_tab_left do
    field_nest :general_overview, view: :titled
  end

  view :details_tab_right do
    field_nest :subtopic, view: :titled, title: "Subtopics", items: { view: :closed }
  end

  view :unknown do
    _render_link
  end

  def default_item_view
    :bar
  end

  def details_tab_cols
    [5, 7]
  end
end
