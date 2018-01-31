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
  all_members.select { |m| m.real? && m.type_id == UserID }
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
      :wikirate_topic,
      :description,
      :organizer
    ]
  end

  view :open_content do |args|
    bs_layout container: false, fluid: true, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _render_about_column, args[:left_class]
        column _render_contributions_column, args[:right_class]
      end
    end
  end

  view :about_column do
    output [
      _render_rich_header,
      field_nest(:description, view: :titled, title: "Description"),
      member_list,
      field_nest(:discussion, view: :titled, show: :comment_box, title: "Discussion")
    ]
  end

  def member_list
    with_header "Members" do
      [:organizer, :researcher].map do |fieldname|
        field_nest fieldname, view: :titled,
                              title: fieldname.cardname,
                              variant: "plural capitalized",
                              type: "Pointer",
                              items: { view: :thumbnail_plain }
      end
    end
  end

  view :listing do
    _render_thumbnail
  end

  view :closed_content do
    ""
  end

  view :contributions_column do
    output [group_contributions, render_member_contribution_section]
  end

  def group_contributions
    with_header "Group Contributions" do
      [render_metrics_designed, render_projects_organized]
    end
  end

  view :metrics_designed do
    field_nest :metric, view: :titled,
                        title: "Metrics Designed",
                        items: { view: :listing }
  end

  view :projects_organized do
    field_nest :project, view: :titled,
                         title: "Projects Organized",
                         items: { view: :listing }
  end

  view :member_contribution_section do
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
    [:created, :updated, :discussed, :double_checked]
  end

  # It could be preferable to have this a separate view, but for that to be
  # practical we'd probably want it to be a view of a User+Research_Group card,
  # because this table is specifically about contributions relevant to the RG.
  # This would probably mean refactoring the handling of report_searches, though.
  # Currently their pattern is [User]+[Cardtype]+[Research Group]+report search.
  # The refactor would make them [User]+[Research Group]+[Cardtype]+report search.
  # So, for now, not a view...
  def member_contribution_content member
    contribution_cardtypes.map do |typecode|
      contribution_categories.map do |category|
        card.contribution_count member.name, typecode, category
      end.unshift typecode.cardname.vary "capitalize plural"
    end
  end
end
