def filter_param field
  (filter = Env.params[:filter]) && filter[field.to_sym]
end

def sort_param
  Env.params[:sort] || default_sort_option
end

format :html do
  delegate :filter_param, to: :card
  delegate :sort_param, to: :card

  def select_filter field, label=nil, default=nil, options=nil
    options ||= filter_options field
    options.unshift(["--", ""]) unless default
    select_filter_tag field, label, default, options
  end

  def multiselect_filter field, label=nil, default=nil, options=nil
    options ||= filter_options field
    multiselect_filter_tag field, label, default, options
  end

  def checkbox_filter field, label=nil, default=nil, options=nil
    name = filter_name field, true
    default = Array(filter_param(field) || default)
    options ||= filter_options field
    label ||= filter_label(field)

    formgroup label do
      options.map do |option|
        checkbox_filter_option option, name, default
      end.join
    end
  end

  def checkbox_filter_option option, tagname, default
    option_name, option_value =
      option.is_a?(Array) ? option : [option, option.downcase]
    checked = default.include?(option_value)
    wrap_with :label do
      [
        check_box_tag(tagname, option_value, checked),
        option_name
      ]
    end
  end

  def text_filter field, opts={}
    name = filter_name field
    add_class opts, "form-control"
    #formgroup filter_label(field), class: "filter-input" do
    text_field_tag name, filter_param(field), opts
    #end
  end

  def select_filter_type_based type_codename, order="asc"
    # take the card name as default label
    options = type_options type_codename, order
    select_filter type_codename, nil, nil, options
  end

  def autocomplete_filter type_codename
    text_filter type_codename, class: "#{type_codename}_autocomplete"
  end

  def multiselect_filter_type_based type_codename
    options = type_options type_codename
    multiselect_filter type_codename, nil, nil, options
  end

  def multiselect_filter_tag field, label, default, options, html_options={}
    html_options[:multiple] = true
    select_filter_tag field, label, default, options, html_options
  end

  def select_filter_tag field, label, default, options, html_options={}
    label ||= filter_label field
    name = filter_name field, html_options[:multiple]
    default = filter_param(field) || default
    options = options_for_select(options, default)

    # these classes make the select field a jquery chosen select field
    css_class =
      html_options[:multiple] ? "pointer-multiselect" : "pointer-select"
    add_class(html_options, css_class + " filter-input #{field} _filter_input_field")

    # formgroup label, class: "filter-input #{field} _filter_input_field" do
      select_tag name, options, html_options
    # end
  end

  def filter_name field, multi=false
    "filter[#{field}]#{'[]' if multi}"
  end

  def filter_label field
    return "Keyword" if field.to_sym == :name
    Card.fetch_name(field) { field.to_s.capitalize }
  end

  def filter_options field
    raw = send("#{field}_options")
    raw.is_a?(Array) ? raw : option_hash_to_array(raw)
  end

  def option_hash_to_array hash
    hash.each_with_object([]) do |(key, value), array|
      array << [key, value.to_s.downcase]
      array
    end
  end

  def type_options type_codename, order="asc"
    type_card = Card[type_codename]
    Card.search type_id: type_card.id, return: :name, sort: "name", dir: order
  end
end
