include_set Abstract::WikirateTable
include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Media
include_set Abstract::BsBadge
include_set Abstract::FilterableBar

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :image, type: :image
card_accessor :wikirate_company
card_accessor :metric

format :html do
  def header_body
    class_up "media-heading", "topic-color"
    super
  end

  view :missing do
    _render_link
  end

  view :bar_left do
    filterable :wikirate_topic do
      render_thumbnail
    end
  end

  view :bar_middle do
    count_badges :wikirate_company, :project
  end

  view :bar_right do
    count_badge :metric
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

  before :content_formgroup do
    voo.edit_structure = %i[image general_overview]
  end

  def tab_list
    %i[metric wikirate_company research_group project]
  end

  view :data do
    field_nest :general_overview, view: :titled
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content, items: { view: :bar }
  end

  view :research_group_tab do
    field_nest :research_group, items: { view: :bar }
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, view: :filtered_content, items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end
end
