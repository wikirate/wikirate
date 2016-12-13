include_set Abstract::TwoColumnLayout

format :html do
  view :open_content do |args|
    bs_layout container: true, fluid: true, class: @container_class do
      row 5, 7 do
        column _optional_render_about_column, args[:left_class]
        column _optional_render_contributions_column, args[:right_class]
      end
    end
  end

  view :about_column do
    output [
      _render_rich_header,
      field_nest(:description, view: :titled),
      _render_members
    ]
  end

  view :members do
    with_header "Members" do
      [:organizer, :researcher].map do |fieldname|
        field_nest fieldname, view: :titled, variant: :plural, type: "Pointer"
      end
    end
  end

  def with_header header
    output [wrap_with(:h2, header), yield]
  end

  view :contributions_column do
    output [group_contributions, member_contributions]
  end

  def group_contributions
    with_header "Group Contributions" do
      [
        # metrics designed
        # projects organized
      ]
    end
  end

  def member_contributions
    with_header "Member Contributions" do
      # all_user_members.map do |user|
      #   nest user, view: :contribution_summary
      # user
    end
  end
end
