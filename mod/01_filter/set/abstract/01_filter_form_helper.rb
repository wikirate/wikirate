format :html do
  def append_formgroup array
    array.map do |key|
      "#{key}_formgroup".to_sym
    end
  end

  def select_filter type_codename, order, label=nil
    # take the card name as default label
    label ||= Card[type_codename].name
    options = type_options type_codename, order
    options.unshift(["--", ""])
    simple_select_filter type_codename.to_s, options, Env.params[type_codename],
                         label
  end

  def simple_select_filter type_name, options, default, label=nil
    select_filter_html type_name, options, default, label
  end

  def select_filter_html type_name, options, default, label, no_chosen=false
    options = options_for_select(options, default)
    label ||= type_name.to_s.capitalize
    css_class = no_chosen ? "" : "pointer-select"
    formgroup label, select_tag(type_name, options, class: css_class),
              class: "filter-input "
  end

  def simple_multiselect_filter type_name, options, default, label=nil
    options = options_for_select(options, default)
    label ||= type_name.capitalize
    multiselect_tag = select_tag(type_name, options,
                                 multiple: true,
                                 class: "pointer-multiselect")
    formgroup(label, multiselect_tag, class: "filter-input #{type_name}")
  end

  def multiselect_filter type_codename, label=nil
    options = type_options type_codename
    label ||= type_codename.to_s
    simple_multiselect_filter type_codename.to_s, options,
                              Env.params[type_codename], label
  end

  def checkbox_filter title, options, default=nil
    key = title.to_name.key
    param = filter_value_from_params(title) || default
    checkboxes = options.map do |option|
      checked = param.present? && param.include?(option.downcase)
      %(<label>
        #{check_box_tag("#{key}[]", option.downcase, checked) + option}
      </label>)
    end
    formgroup title, checkboxes.join("")
  end

  def type_options type_codename, order="asc"
    type_card = Card[type_codename]
    Card.search type_id: type_card.id, return: :name, sort: "name", dir: order
  end

  def text_filter type_name, args
    formgroup args[:title] || type_name.capitalize,
              text_field_tag(type_name, params[type_name],
                             class: "form-control"),
              class: " filter-input"
  end
  view :name_formgroup do |args|
    name = args[:name] || "name"
    title = args[:title] || "Keyword"
    text_filter name, title: title
  end

end