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
  def header_body size=:medium
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
    output [render_bar_middle, render_details_tab]
  end

  view :box_middle do
    nest image_card, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges :wikirate_company, :metric
  end

  bar_cols 7, 5
  info_bar_cols 5, 4, 3

  before :content_formgroup do
    voo.edit_structure = %i[image general_overview]
  end

  def tab_list
    %i[details wikirate_company project]
  end

  view :data, cache: :never do
    field_nest :metric, title: "Metrics",
                        view: :filtered_content, items: { view: :bar }
  end

  view :details_tab do
    field_nest :general_overview, view: :titled
  end

  view :wikirate_company_tab do
    field_nest :wikirate_company, title: "Companies", items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end
end
