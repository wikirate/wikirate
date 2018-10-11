include_set Abstract::BsBadge

format :html do
  view :tabs, cache: :never do
    lazy_loading_tabs tab_map, default_tab do
      _render! default_tab
    end
  end

  def tab_map
    options = tab_options
    tab_list.each_with_object({}) do |codename, hash|
      hash[:"#{codename}_tab"] = tab_title codename, options[codename]
    end
  end

  def tab_list
    []
  end

  def tab_options
    {}
  end

  def default_tab
    tab_from_params || tab_map.keys.first
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

  def tab_title fieldcode, opts={}
    opts ||= {}
    parts = tab_title_parts fieldcode, opts
    two_line_tab parts[:label], tab_title_top(parts[:icon], parts[:count])
  end

  def tab_title_top icon, count
    icon_tag = tab_title_icon_tag icon
    if count
      tab_count_badge count, icon_tag
    else
      icon_tag || "&nbsp;".html_safe
    end
  end

  def tab_count_badge count, icon_tag
    klass = nil
    if count.is_a? Card
      klass = css_classes count.safe_set_keys
      count = count.count
    end
    tab_badge count, icon_tag, klass: klass
  end

  def tab_title_icon_tag icon
    return unless icon.present?
    icon_tag(*Array.wrap(icon))
  end

  def tab_title_parts fieldcode, opts
    %i[count icon label].each_with_object({}) do |part, hash|
      hash[part] = opts.key?(part) ? opts[part] : send("tab_title_#{part}", fieldcode)
    end
  end

  def tab_title_count fieldcode
    field_card = card.fetch trait: fieldcode
    field_card if field_card.respond_to? :count
  end

  def tab_title_icon fieldcode
    icon_map fieldcode
  end

  def tab_title_label fieldcode
    fieldcode.cardname.vary :plural
  end
end
