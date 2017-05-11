include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail

format :html do
  view :open_content do |args|
    bs_layout container: false, fluid: false, class: @container_class do
      row 5, 7, class: "panel-margin-fix" do
        column _render_content_left_col, args[:left_class]
        column _render_contributions_column, args[:right_class]
      end
    end
  end

  view :data do
    # return "deleteme"
    wrap_with :div, class: "profile-data" do
      [
        field_nest("+about me", view: :titled, title: "About me", hide: :menu),
        content_tag(:hr),
        field_nest(:discussion, view: :titled, title: "Discussion", show: :comment_box),
        content_tag(:hr),
        field_nest(:activity, view: :titled, title: "Activity", hide: :menu)
        # TODO: restore following soon
        # field_nest(:follow, view: :profile,
        #                    hide: [:menu, :toggle],
        #                    title: "Following",
        #                    items: {
        #                      view: :content,
        #                      structure: "User following result row"
        #                    })
      ]
    end
  end

  view :contributions_column do
    wrap_with :div, class: "contributions-column" do
      [wrap_with(:h4, "Contributions"), contribution_reports]
    end
  end

  def contribution_types
    [:metric_value, :metric, :wikirate_company, :project, :source,
     :wikirate_topic, :research_group, :claim]
  end

  def contribution_reports
    contribution_types.map do |codename|
      user_and_type = card.fetch trait: codename, new: {}
      nest user_and_type, view: :contribution_report
    end
  end
end
