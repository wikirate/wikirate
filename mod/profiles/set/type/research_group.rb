include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Table
include_set Abstract::BsBadge
include_set Abstract::Bookmarkable

card_accessor :organizer
card_accessor :researcher
card_accessor :project
card_accessor :metric
card_accessor :wikirate_topic

def report_card member, cardtype, variant
  rcard = Card.new name: [member, cardtype, name, :report_search]
  # note: #new is important here, because we want different cards
  # for different variants
  rcard.variant = variant
  rcard
end

def contribution_count member, cardtype, category
  return 0 if projects.empty?
  return "" if category == :double_checked && cardtype != :metric_answer
  report_card(member, cardtype, category).count
end

def projects
  @projects ||= project_card.item_cards limit: 0
end

format :html do
  before :content_formgroups do
    voo.edit_structure = [
      :image,
      :organizer,
      :wikirate_topic,
      :description
    ]
  end

  info_bar_cols 5, 5, 2

  view :open_content do
    two_column_layout 5, 7
  end

  view :data do
    [organizer_detail,
     topic_detail,
     field_nest(:description, view: :titled),
     standard_nest(:conversation)]
  end

  def organizer_detail
    labeled_field :organizer, :thumbnail, title: "Group Organizer"
  end

  def topic_detail
    labeled_field :wikirate_topic, :link, title: "Topics"
  end

  def thumbnail_subtitle
    field_nest :organizer, view: :credit
  end

  def tab_list
    %i[researcher project metric]
  end

  view :metric_tab do
    field_nest :metric, items: { view: :bar }
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end

  view :researcher_tab do
    field_nest :researcher, view: :overview
  end

  view :bar_left do
    render_thumbnail_with_bookmark
  end

  view :bar_middle do
    field_nest :wikirate_topic, items: { view: :link }
  end

  view :bar_right do
    count_badges :researcher, :project, :metric
  end

  view :bar_bottom do
    render_data
  end

  view :one_line_content do
    ""
  end
end
