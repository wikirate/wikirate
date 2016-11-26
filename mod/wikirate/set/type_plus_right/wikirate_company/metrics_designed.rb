include_set Abstract::WikirateTable

format :html do
  view :core do
    yinyang_list
  end

  def yinyang_list
    voo.items[:view] = :metric_row
    wrap_with :div, class: "yinyang-list" do
      _render_card_list
    end
  end
end

