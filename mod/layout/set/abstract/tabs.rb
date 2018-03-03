format :html do
  view :tabs, cache: :never do
    lazy_loading_tabs tab_list, default_tab do
      _render! default_tab
    end
  end

  def tab_list
    {}
  end

  def default_tab
    tab_from_params || tab_list.keys.first
  end

  def tab_from_params
    return unless Env.params[:tab]
    "#{Env.params[:tab]}_tab".to_sym
  end

  def tab_wrap
    bs_layout do
      row 12 do
        col output(yield), class: "padding-top-10"
      end
    end
  end

  def tab_url tab
    path tab: tab
  end
end
