format :html do
  before :content_formgroups do
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
    wrap_with :div, class: "dataset-details" do
      dataset_details
    end
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link,
       render_tabs,
       render_export_links,
       render_import_links]
    end
  end

  def tab_list
    [:wikirate_company, :metric].compact
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :menued
  end

  view :metric_tab do
    field_nest :metric, view: :menued
  end

  view :data_subset_tab, template: :haml

  # left column content
  def dataset_details
    wrap_with :div do
      [
        data_subset_detail,
        labeled_field(:wikirate_status),
        labeled_field(:wikirate_topic, :link, title: "Topics")
      ]
    end
  end

  def copied_dataset_fields
    %i[wikirate_topic description].each_with_object({}) do |fld, hash|
      hash["_#{fld.cardname}"] = card.fetch(fld, new: {}).content
    end
  end
end
