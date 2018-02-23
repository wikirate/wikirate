include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Table
include_set Abstract::Listing
include_set Abstract::BsBadge

card_accessor :organizer
card_accessor :researcher
card_accessor :project
card_accessor :metric
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
    { researcher_list: two_line_tab("Researchers", card.researcher_card.count),
      metric_list:     two_line_tab("Metrics",     card.metric_card.count    ),
      project_list:    two_line_tab("Projects",    card.project_card.count   ) }
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

  view :listing_left, template: :haml
  view :listing_bottom, template: :haml
  view :listing_middle, template: :haml

  view :listing_right, cache: :never do
    bs_badge card.researcher_card.count, "Researchers"
  end

  view :minor_bs_badges, cache: :never do
    wrap_with :span do
      [bs_badge(card.metric_card.count, "Metrics"),
       bs_badge(card.project_card.count, "Projects")]
    end
  end

  view :closed_content do
    ""
  end
end
