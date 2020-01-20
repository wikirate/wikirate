format :html do
  def header_body
    class_up "media-heading", "topic-color"
    super
  end

  view :unknown do
    _render_link
  end

  bar_cols 7, 5

  before :content_formgroups do
    # voo.edit_structure = %i[image subtopic general_overview]
    voo.edit_structure = %i[image general_overview]
  end

  def tab_list
    %i[metric research_group project]
  end

  def tab_options
    { research_group: { label: "Research Groups" } }
  end

  view :data do
    [
      field_nest(:subtopic, view: :titled, title: "Subtopics", items: { view: :bar }),
      field_nest(:general_overview, view: :titled)
    ]
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content, items: { view: :bar }
  end

  view :research_group_tab do
    field_nest :research_group, items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end
end
