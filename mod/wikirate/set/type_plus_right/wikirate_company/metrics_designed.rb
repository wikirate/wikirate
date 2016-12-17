include_set Abstract::Table

format :html do
  view :core do
    wikirate_table :metric,
                   ["Metric", "Companies"], search_with_params,
                   [:simple_item_view, :company_count]
  end

  def yinyang_list
    voo.items[:view] = :metric_row
    wrap_with :div, class: "yinyang-list" do
      _render_card_list
    end
  end
end

