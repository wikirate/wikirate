include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::FilterableBar
include_set Abstract::Bookmarkable

card_accessor :image, type: :image
card_accessor :wikirate_company
card_accessor :specification

format :html do
  def header_body
    class_up "media-heading", "company-group-color"
    super
  end

  view :bar_left do
    render_thumbnail_with_bookmark
  end

  view :bar_right do
    count_badge :wikirate_company
  end

  view :bar_bottom do
    [render_bar_middle, render_data]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :wikirate_company
  end

  bar_cols 7, 5

  before :content_formgroups do
    voo.edit_structure = %i[image specification wikirate_company about discussion]
  end

  def tab_list
    %i[wikirate_company]
  end

  view :data do
    [
      field_nest(:specification, view: :titled),
      field_nest(:about, view: :titled),
      field_nest(:discussion, view: :titled)
    ]
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :filtered_content
  end
end
