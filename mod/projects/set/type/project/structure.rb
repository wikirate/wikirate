include_set Abstract::TwoColumnLayout

format :html do
  before :content_formgroup do
    voo.edit_structure = [
      :image,
      :wikirate_status,
      :parent,
      :organizer,
      :wikirate_topic,
      :description,
      :year,
      :metric,
      :wikirate_company
    ]
  end

  before :open do
    voo.hide! :header
  end

  view :open_content do
    two_column_layout 5, 7
  end

  view :data do
    wrap_with :div, class: "project-details" do
      project_details
    end
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link, overall_progress_box, _render_tabs, _render_export_links]
    end
  end

  def tab_list
    [:wikirate_company, :metric, (:year if card.years), :subproject].compact
  end

  def tab_options
    { year: { count: card.num_years } }
  end

  view :metric_tab do
    tab_nest :metric
  end

  view :wikirate_company_tab do
    tab_nest :wikirate_company
  end

  view :year_tab do
    tab_nest :year
  end

  view :subproject_tab, template: :haml

  # left column content
  def project_details
    wrap_with :div do
      [
        subproject_detail,
        labeled_field(:wikirate_status),
        labeled_field(:organizer, :thumbnail_plain),
        labeled_field(:wikirate_topic, :link, title: "Topics"),
        field_nest(:description, view: :titled),
        field_nest(:conversation, view: :titled)
      ]
    end
  end

  def copied_project_fields
    %i[wikirate_topic description].each_with_object({}) do |fld, hash|
      hash["_#{fld.cardname}"] = card.fetch(trait: fld, new: {}).content
    end
  end
end
