include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail

CONTRIBUTION_TYPES = %i[metric_value metric wikirate_company project
                        source wikirate_topic research_group].freeze

format :html do
  def default_content_formgroup_args _args
    voo.edit_structure = [:image, "+about me", :discussion]
  end

  view :open_content do
    two_column_layout 5, 7
  end

  view :data do
    # return "deleteme"
    wrap_with :div, class: "profile-data" do
      [
        field_nest("+about me", view: :titled, title: "About me"),
        content_tag(:hr),
        field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box),
        content_tag(:hr),
        field_nest(:activity, view: :titled, title: "Activity", hide: :menu)
      ]
    end
  end

  view :right_column do
    output [wrap_with(:h4, "Contributions"), contribution_reports]
  end

  def right_column_class
    "#{super} contributions-column"
  end

  def contribution_reports
    CONTRIBUTION_TYPES.map do |codename|
      user_and_type = card.fetch trait: codename, new: {}
      nest user_and_type, view: :contribution_report
    end
  end
end
