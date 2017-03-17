include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Table

card_accessor :organizer
card_accessor :researcher
card_accessor :project

def all_members
  (organizer_card.item_cards + researcher_card.item_cards).uniq
end

def all_user_members
  all_members.select { |m| m.type_id == UserID }
end

def report_card member, cardtype, variant
  rcard = Card.new name: [member, cardtype, name, :report_search].to_name
  # note: #new is important here, because we want different cards
  # for different variants
  rcard.variant = variant
  rcard
end

def contribution_count member, cardtype, category
  return 0 if projects.empty?
  report_card(member, cardtype, category).count
end

def projects
  @projects ||= project_card.item_cards limit: 0
end

format :html do
  view :open_content do |args|
    bs_layout container: false, fluid: true, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _optional_render_about_column, args[:left_class]
        column _optional_render_contributions_column, args[:right_class]
      end
    end
  end

  view :about_column do
    output [
      _render_rich_header,
      field_nest(:description, view: :titled, title: "Description"),
      member_list,
      field_nest(:discussion, view: :titled, show: :comment_box,
                              title: "Discussion")
    ]
  end

  def member_list
    with_header "Members" do
      [:organizer, :researcher].map do |fieldname|
        field_nest fieldname, view: :titled,
                              title: fieldname.cardname.s,
                              variant: "plural capitalized",
                              type: "Pointer",
                              items: { view: :thumbnail_plain }
      end
    end
  end

  view :listing do
    _render_thumbnail
  end

  view :contributions_column do
    output [group_contributions, member_contribution_section]
  end

  def group_contributions
    with_header "Group Contributions" do
      [metrics_designed, projects_organized]
    end
  end

  def metrics_designed
    field_nest :metric, view: :titled,
                        title: "Metrics Designed",
                        items: { view: :listing }
  end

  def projects_organized
    field_nest :project, view: :titled,
                         title: "Projects Organized",
                         items: { view: :listing }
  end

  def member_contribution_section
    with_header "Member Contributions" do
      card.all_user_members.map do |member|
        member_contribution_table member
      end
    end
  end

  def member_contribution_table member
    table member_contribution_content(member),
          header: member_contribution_header(member)
  end

  def member_contribution_header member
    contribution_categories.map do |category|
      Card::Set::LtypeRtype::User::Cardtype::ACTION_LABELS[category]
    end.unshift nest(member, view: :thumbnail)
  end

  def contribution_cardtypes
    [:metric_value, :metric, :wikirate_company]
    # TODO: consider adding source, which is connected via metric_value
  end

  def contribution_categories
    [:created, :updated, :discussed]
  end

  def member_contribution_content member
    contribution_cardtypes.map do |cardtype|
      contribution_categories.map do |category|
        card.contribution_count member.name, cardtype, category
      end.unshift cardtype.cardname.vary "capitalize plural"
    end
  end
end
