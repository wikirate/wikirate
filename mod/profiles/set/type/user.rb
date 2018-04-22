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
    wrap_with :div, class: "profile-data" do
      [
        field_nest("+about me", view: :titled, title: "About me"),
        content_tag(:hr),
        field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box)
      ]
    end
  end

  def tab_list
    %i[research_group contributions activity]
  end

  def tab_options
    {
      contributions: { count: nil, label: "Contributions" },
      activity: { count: nil, label: "Activity" }
    }
  end

  view :research_group_tab, cache: :never do
    field_nest :research_group, items: { view: :thin_listing }
  end

  view :contributions_tab, cache: :never do
    CONTRIBUTION_TYPES.map do |codename|
      user_and_type = card.fetch trait: codename, new: {}
      nest user_and_type, view: :contribution_report
    end.join
  end

  view :activity_tab, cache: :never do
    field_nest :activity
  end
end
