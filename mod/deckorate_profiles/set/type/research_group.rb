include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Table
include_set Abstract::Bookmarkable
include_set Abstract::Designer

card_accessor :organizer, type: :list
card_accessor :researcher, type: :list
card_accessor :project, type: :search_type
card_accessor :metric, type: :search_type
card_accessor :topic, type: :list
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
  return "" if category == :double_checked && cardtype != :answer
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
      # :topic,
      :description
    ]
  end

  bar_cols 7, 5

  def organizer_detail
    labeled_field :organizer, :thumbnail, title: "Group Organizer"
  end

  # def topic_detail
  #   labeled_field :topic, :link, title: "Topics"
  # end

  def thumbnail_subtitle
    field_nest :organizer, view: :credit
  end

  def tab_list
    %i[details researcher project metric]
  end

  view :metric_tab do
    field_nest :metric, view: :filtered_content
  end

  view :project_tab do
    field_nest :project, items: { view: :bar }
  end

  view :researcher_tab do
    field_nest :researcher, view: :overview
  end

  view :bar_left do
    render_thumbnail
  end

  view :bar_middle do
    "" # result_middle { field_nest :topic, items: { view: :link } }
  end

  view :bar_right do
    [count_badges(:researcher, :project, :metric), render_bookmark]
  end

  view :bar_bottom do
    [render_details_tab_right, render_details_tab_left]
  end

  view :box_middle do
    field_nest :image, view: :core, size: :medium
  end

  view :box_bottom do
    count_badges(:researcher, :project, :metric)
  end

  view :one_line_content do
    ""
  end

  view :details_tab_left do
    [
      field_nest(:description, view: :titled)
    ]
  end

  view :details_tab_right do
    # labeled_fields { [organizer_detail, topic_detail] }
    labeled_fields { [organizer_detail] }
  end
end
