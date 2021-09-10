format :html do
  before :content_formgroups do
    voo.edit_structure =
      %i[image parent wikirate_topic year wikirate_company metric description]
  end

  before :open do
    voo.hide! :header
  end

  view :open_content do
    two_column_layout 5, 7
  end

  view :data do
    wrap_with(:div, class: "dataset-details") { dataset_details }
  end

  view :right_column do
    wrap_with(:div, class: "progress-column") { [render_type_link, render_tabs] }
  end

  def tab_list
    %i[metric_answer wikirate_company metric data_subset]
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :menued
  end

  view :metric_tab do
    field_nest :metric, view: :menued
  end

  view :metric_answer_tab do
    [field_nest(:metric_answer, view: :filtered_content), render_import_links]
  end

  # view :project_tab, template: :haml
  view :data_subset_tab, template: :haml

  # left column content
  def dataset_details
    wrap_with :div do
      [
        data_subset_detail,
        labeled_field(:year, :name, title: "Years", unknown: :blank, separator: ", "),
        labeled_field(:wikirate_topic, :link, title: "Topics"),
        labeled_field(:project, :thumbnail, title: "Projects"),
        field_nest(:description)
      ]
    end
  end

  def copied_dataset_fields
    %i[wikirate_topic description].each_with_object({}) do |fld, hash|
      hash["_#{fld.cardname}"] = card.fetch(fld, new: {}).content
    end
  end
end
