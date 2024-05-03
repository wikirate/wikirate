include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Table
include_set Abstract::Bookmarkable

card_accessor :organizer, type: :list
card_accessor :researcher, type: :list
card_accessor :project, type: :search_type
card_accessor :metric, type: :search_type
card_accessor :wikirate_topic, type: :list
card_reader :metrics_designed, type: :search_type
card_reader :projects_organized, type: :search_type

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

  bar_cols 7, 5

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
    %i[details researcher project metric]
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

  view :details_tab do
    render_details
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_middle do
    result_middle { field_nest :wikirate_topic, items: { view: :link } }
  end

  view :bar_right do
    [count_badges(:researcher, :project, :metric), render_bookmark]
  end

  view :bar_bottom do
    render_details
  end

  view :one_line_content do
    ""
  end

  view :details do
    [labeled_fields { [organizer_detail, topic_detail] },
     field_nest(:description, view: :titled),
     field_nest(:conversation, items: { view: :link })]
  end
end
