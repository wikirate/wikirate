include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Table
include_set Abstract::Listing

card_accessor :organizer
card_accessor :researcher
card_accessor :project
card_accessor :wikirate_topic

def report_card member, cardtype, variant
  rcard = Card.new name: [member, cardtype, name, :report_search].to_name
  # note: #new is important here, because we want different cards
  # for different variants
  rcard.variant = variant
  rcard
end

def contribution_count member, cardtype, category
  return 0 if projects.empty?
  return "" if category == :double_checked && cardtype != :metric_value
  report_card(member, cardtype, category).count
end

def projects
  @projects ||= project_card.item_cards limit: 0
end

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [
      :image,
      :organizer,
      :wikirate_topic,
      :description
    ]
  end

  view :open_content do
    two_column_layout 5, 7
  end

  view :data do
     output [
       field_nest(:organizer, view: :titled,
                              title: "Organizer",
                              items: { view: :thumbnail_plain }),
       standard_nest(:wikirate_topic),
       field_nest(:description, view: :titled, title: "Description"),
       standard_nest(:conversation)
     ]
  end

  def tab_list
    { researcher_list: "Researchers",
      metric_list:     "Metrics",
      project_list:    "Projects" }
  end

  view :metric_list do
    field_nest :metric, items: { view: :listing }
  end

  view :project_list do
    field_nest :project, items: { view: :listing }
  end

  view :researcher_list do
    field_nest :researcher, view: :overview
  end

  view :listing_left do
    render_thumbnail
  end

  view :listing_middle do
    "metrics, projects"
  end

  view :listing_right do
    "researchers"
  end

  view :closed_content do
    ""
  end
end
