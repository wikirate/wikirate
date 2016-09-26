format :html do
  view :tabs do |args|
    lazy_loading_tabs args[:tabs], args[:default_tab],
                      render("#{args[:default_tab]}_tab", skip_permission:
                        true)
  end
  def default_tabs_args args
    args[:tabs] = {
      "Details" => path(view: "details_tab"),
      "#{fa_icon :comment} Discussion" => path(view: "discussion_tab")
    }
    args[:default_tab] = "Details"
  end

  # tabs for metrics of type formula, score and WikiRating
  # overridden for researched
  view :details_tab do
    tab_wrap do
      [
        _render_metric_properties,
        content_tag(:hr, ""),
        nest(card.formula_card, view: :titled, title: "Formula"),
        nest(card.about_card, view: :titled, title: "About")
      ]
    end
  end

  def tab_wrap
    wrap_with :div, class: "row" do
      wrap_with :div, class: "col-md-12 padding-top-10" do
        yield
      end
    end
  end

  view :discussion_tab do |_args|
    tab_wrap do
      field_subformat(:discussion).render_titled home_view: "titled",
                                                 hide: [:header, :title],
                                                 show: "comment_box"
    end
  end
end
