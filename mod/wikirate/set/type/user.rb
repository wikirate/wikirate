include_set Abstract::TwoColumnLayout

format :html do
  view :open_content do |args|
    bs_layout container: true, fluid: true, class: @container_class do
      row 5, 7 do
        column _render_content_left_col, args[:left_class]
        column _render_contributions_column, args[:right_class]
      end
    end
  end

  view :data do
    return "deleteme"
    wrap_with :div, class: "profile-data" do
      [
        field_nest(:activity, view: :titled, title: "Activity", hide: :menu),
        # what is this craziness? shouldn't this just be a view?
        field_nest(:follow, view: :profile,
                            hide: [:menu, :toggle],
                            title: "Following",
                            items: {
                              view: :content,
                              structure: "User following result row"
                            })
      ]
    end
  end

  view :contributions_column do
    wrap_with :div, class: "contributions-column" do
      [
        wrap_with(:h4, "Contributions"),
        contribution_reports
      ]
    end
  end

  def contribution_reports
    [
      :metric_value, :metric, :wikirate_company, :project, :source,
      :wikirate_topic, :claim
    ].map do |codename|
      user_and_type = card.fetch trait: codename, new: {}
      nest user_and_type, view: :contribution_report
    end
  end
end
