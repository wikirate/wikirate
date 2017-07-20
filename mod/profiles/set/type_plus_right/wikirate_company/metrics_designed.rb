include_set Abstract::Table
include_set Abstract::Paging

format :html do
  def default_search_params
    super.merge(return: :card)
  end

  view :core do
    with_paging do
      wikirate_table :metric,
                     search_with_params,
                     [:thumbnail, :company_count],
                     header: %w[Metric Companies]
    end
  end

  def yinyang_list
    voo.items[:view] = :metric_row
    wrap_with :div, class: "yinyang-list" do
      _render_card_list
    end
  end
end
