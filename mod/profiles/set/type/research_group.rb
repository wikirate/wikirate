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

  def header_right
    wrap_with :div, class: "header-right" do
      [
        wrap_with(:h6, card.type.upcase, class: "text-muted border-bottom pt-2 pb-2"),
        wrap_with(:h5, _render_title, class: "project-title font-weight-normal")
      ].compact
    end
  end

  view :rich_header_body do
    text_with_image title: "", text: header_right, size: :medium
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

  view :thumbnail_subtitle do
    field_nest :organizer, view: :credit
  end

  def tab_list
    %i[researcher metric project]
  end

  def tab_options
    tab_list.each_with_object({}) do |codename, hash|
      hash[codename] = { count: card.send("#{codename}_card").count }
    end
  end

  view :metric_tab do
    field_nest :metric, items: { view: :listing }
  end

  view :project_tab do
    field_nest :project, items: { view: :listing }
  end

  view :researcher_tab do
    field_nest :researcher, view: :overview
  end

  view :listing_left, template: :haml
  view :listing_bottom, template: :haml
  view :listing_middle, template: :haml

  view :listing_right, cache: :never do
    labeled_badge card.researcher_card.count, "Researchers", color: "dark"
  end

  view :minor_labeled_badges, cache: :never do
    wrap_with :span do
      [labeled_badge(card.metric_card.count, "Metrics"),
       labeled_badge(card.project_card.count, "Projects")]
    end
  end

  view :closed_content do
    ""
  end
end
