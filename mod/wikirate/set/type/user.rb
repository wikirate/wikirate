include_set Abstract::TwoColumnLayout

format :html do
  view :open_content do |args|
    bs_layout container: true, fluid: true, class: @container_class do
      row 5, 7 do
        column _render_content_left_col, args[:left_class]
        column _render_contributions_col, args[:right_class]
      end
    end
  end

  view :data do
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

  view :contributions_col do
    wrap_with :div, class: "contributions-column" do
      [
        wrap_with(:h4, "Contributions")
      ]
    end
  end
end
