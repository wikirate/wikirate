include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::CachedTypeOptions

card_accessor :image, type: :image
card_accessor :company, type: :list
card_accessor :specification
card_accessor :topic, type: :list

format :html do
  view :bar_left do
    render_thumbnail
  end

  view :bar_right do
    [count_badge(:company), render_bookmark]
  end

  view :bar_bottom do
    [render_bar_middle, render_details_tab_right, render_details_tab_left]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :company
  end

  mini_bar_cols 7, 5

  before :content_formgroups do
    voo.edit_structure =
      %i[image topic specification company about discussion]
  end

  def tab_list
    %i[details company metric]
  end

  view :company_tab do
    field_nest :company, view: :filtered_content
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :details_tab_left do
    [
      field_nest(:specification, view: :titled),
      field_nest(:about, view: :titled),
      field_nest(:discussion, view: :titled)
    ]
  end

  view :details_tab_right do
    labeled_fields do
      labeled_field :topic, :link, title: "Topics", unknown: :blank
    end
  end
end
