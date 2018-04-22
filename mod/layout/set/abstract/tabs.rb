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
    icon = icon_tag(*Array.wrap(parts[:icon]))
    two_line_tab parts[:label], [parts[:count], icon].compact.join(" ")
  end

  def tab_title_parts fieldcode, opts
    %i[count icon label].each_with_object({}) do |part, hash|
      hash[part] = opts.key?(part) ? opts[part] : send("tab_title_#{part}", fieldcode)
    end
  end

  def tab_title_count fieldcode
    field_card = card.fetch trait: fieldcode
    field_card.cached_count if field_card.respond_to? :cached_count
  end

  def tab_title_icon fieldcode
    icon_map(fieldcode) || raise(Card::Error::NotFound, "no icon for #{fieldcode}")
  end

  def tab_title_label fieldcode
    fieldcode.cardname.vary :plural
  end
end
