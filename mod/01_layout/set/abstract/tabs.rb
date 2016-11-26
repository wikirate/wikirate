format :html do
  view :tabs do
    lazy_loading_tabs tab_list, default_tab do
      _render default_tab
    end
  end

  def tab_list
    {}
  end

  def default_tab
    tab_list.keys.first
  end

  def tab_wrap
    bs_layout do
      row 12 do
        col yield, class: "padding-top-10"
      end
    end
  end
end
