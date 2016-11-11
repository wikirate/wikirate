def filter_param field
  (filter = Env.params[:filter]) && filter[field]
end

format :html do
  def append_formgroup array
    array.map do |key|
      "#{key}_formgroup".to_sym
    end
  end

  def select_filter type_codename, order, label=nil
    # take the card name as default label
    label ||= filter_label type_codename
    options = type_options type_codename, order
    options.unshift(["--", ""])
    simple_select_filter type_codename.to_s,
                         options,
                         filter_param(type_codename),
                         label
  end

  def simple_select_filter filter_field, options, default, label=nil
    default = filter_param(filter_field) || default
    select_filter_tag filter_field, options, default, label
  end


  def simple_multiselect_filter type_name, options, default, label=nil
    options = options_for_select(options, default)
    label ||= type_name.capitalize
    name = filter_name type_name, true
    multiselect_tag = select_tag(name, options,
                                 multiple: true,
                                 class: "pointer-multiselect")
    formgroup(label, class: "filter-input #{type_name}") do
      multiselect_tag
    end
  end

  def multiselect_filter filter_field, label=nil
    options = type_options filter_field
    label ||= filter_field.to_s
    default = filter_param(filter_field)
    simple_multiselect_filter filter_field.to_s, options,
                              default, label
  end

  def checkbox_filter title, options, default=nil
    key = title.to_name.key
    param = filter_value_from_params(title) || default
    checkboxes = options.map do |option|
      checked = param.present? && param.include?(option.downcase)
      name = filter_name key, true
      %(<label>
        #{check_box_tag(name, option.downcase, checked) + option}
      </label>)
    end
    formgroup(title) { checkboxes.join("") }
  end

  def type_options type_codename, order="asc"
    type_card = Card[type_codename]
    Card.search type_id: type_card.id, return: :name, sort: "name", dir: order
  end

  def text_filter type_name, args
    name = filter_name type_name
    formgroup args[:title] || type_name.capitalize, class: " filter-input" do
      text_field_tag name, params[type_name], class: "form-control"
    end
  end

  view :name_formgroup do |args|
    name = args[:name] || "name"
    title = args[:title] || "Keyword"
    text_filter name, title: title
  end


  def select_filter_tag type_name, options, default, label, no_chosen=false
    options = options_for_select(options, default)
    label ||= filter_label type_name
    css_class = no_chosen ? "" : "pointer-select"
    name = filter_name type_name
    formgroup label, class: "filter-input " do
      select_tag(name, options, class: css_class)
    end
  end

  def filter_name name, multi=false
    "filter[#{name}]#{'[]' if multi}"
  end

  def filter_label field
    Card.fetch_name(field) { field.to_s.capitalize }
  end

  delegate :filter_param, to: :card
end
