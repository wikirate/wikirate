include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::CachedTypeOptions

card_accessor :image, type: :image
card_accessor :wikirate_company, type: :list
card_accessor :specification
card_accessor :wikirate_topic, type: :list

format :html do
  view :bar_left do
    render_thumbnail
  end

  view :bar_right do
    [count_badge(:wikirate_company), render_bookmark]
  end

  view :bar_bottom do
    [render_bar_middle, render_details]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :wikirate_company
  end

  mini_bar_cols 7, 5

  before :content_formgroups do
    voo.edit_structure =
      %i[image wikirate_topic specification wikirate_company about discussion]
  end

  def tab_list
    %i[details wikirate_company]
  end

  view :details_tab do
    render_details
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :filtered_content
  end

  view :details do
    [
      labeled_fields do
        labeled_field(:wikirate_topic, :link, title: "Topics", unknown: :blank)
      end,
      field_nest(:specification, view: :titled),
      field_nest(:about, view: :titled),
      field_nest(:discussion, view: :titled)
    ]
  end
end
