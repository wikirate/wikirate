include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::FilterableBar

card_accessor :image, type: :image
card_accessor :wikirate_company
card_accessor :specification

format :html do
  def header_body
    class_up "media-heading", "company-group-color"
    super
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_middle do
    count_badges :wikirate_company, :project
  end

  view :bar_right do
    count_badge :company
  end

  view :bar_bottom do
    [render_bar_middle, render_data]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :wikirate_company, :metric
  end

  bar_cols 7, 5

  before :content_formgroups do
    voo.edit_structure = %i[image specification about discussion]
  end

  def tab_list
    %i[wikirate_company]
  end

  def tab_options
    { research_group: { label: "Groups" } }
  end

  view :data do
    [
      field_nest(:specification, view: :titled),
      field_nest(:about, view: :titled),
      field_nest(:discussion, view: :titled),
    ]
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :filtered_content, items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end
end
