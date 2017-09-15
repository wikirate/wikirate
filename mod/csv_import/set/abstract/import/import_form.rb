format :html do
  def default_new_args _args
    voo.help = help_text
    voo.show! :help
  end

  def help_text
    rows = import_fields.map { |s| s.to_s.sub("file_", "").humanize }
    voo.help = "expected csv format: #{rows.join ' | '}"
  end

  def import_fields
    [:file_company, :value]
  end

  def new_view_hidden
    hidden_tags success: { id: "_self", soft_redirect: false, view: :import }
  end

  def humanized_attachment_name
    "csv file"
  end

  view :import, cache: :never do
    frame_and_form :update, "notify-success" => "import successful" do
      [
        hidden_import_tags,
        _optional_render(:metric_select),
        _optional_render(:year_select),
        _optional_render(:import_flag),
        _optional_render(:import_table_helper),
        _optional_render(:import_table),
        _optional_render(:import_button_formgroup)
      ]
    end
  end

  def hidden_import_tags
    hidden_tags success: { id: "_self", view: :open }
  end

  view :import_button_formgroup do
    button_formgroup { [import_button, cancel_button(href: path)] }
  end

  def import_button
    button_tag "Import", class: "submit-button",
                         data: { disable_with: "Importing" }
  end

  view :year_select do
    nest card.left.year_card, view: :edit_in_form
  end

  view :metric_select do
    nest card.left.metric_card, view: :edit_in_form
  end

  view :import_flag do
    hidden_field_tag :is_data_import, "true"
  end

  view :import_table_helper do
    wrap_with :p, group_selection_checkboxes #+ import_legend)
  end

  def group_selection_checkboxes
    <<-HTML.html_safe
      Select:
      <span class="padding-20 background-grey">
        #{check_box_tag '_check_all', '', false, class: 'checkbox-button'}
        #{label_tag 'all'}
      </span>
      #{group_selection_checkbox('exact', 'exact matches', :success, true)}
      #{group_selection_checkbox('alias', 'alias matches', :info, true)}
      #{group_selection_checkbox('partial', 'partial matches', :warning, true)}
      #{group_selection_checkbox('none', 'no matches', :danger)}
    HTML
  end

  def group_selection_checkbox name, label, identifier, checked=false
    wrap_with :span, class: "padding-20 bg-#{identifier}" do
      [
        check_box_tag(
          name, "", checked,
          class: "checkbox-button _group_check",
          data: { group: identifier }
        ),
        label_tag(label)
      ]
    end
  end

  def import_legend
    <<-HTML.html_safe
     <span class="pull-right">
      company match:
      #{row_legend 'exact', 'success'}
      #{row_legend 'alias', 'info'}
      #{row_legend 'partial', 'warning'}
      #{row_legend 'none', 'danger'}
     <span>
    HTML
  end

  def row_legend text, context
    bs_label text, class: "bg-#{context}",
                   style: "color: inherit;"
  end

  def bs_label text, opts={}
    add_class opts, "label"
    add_class opts, "label-#{opts.delete(:context)}" if opts[:context]
    wrap_with :span, text, opts
  end

  def default_import_table_args args
    args[:table_header] = ["Import", "#", "Company in File",
                           "Company in Wikirate", "Correction"]
    args[:table_fields] = [:checkbox, :row, :file_company, :wikirate_company,
                           :correction]
  end

  view :import_table, cache: :never do |args|
    return alert(:warning) { "no import file attached" } if card.file.blank?

    data = card.csv_rows
    reject_header_row data
    data = prepare_and_sort_rows data, args
    data = data.map.with_index do |elem, i|
      import_table_row(elem, args[:table_fields], i + 1)
    end

    table data, class: "import_table table-bordered table-hover",
                header: args[:table_header]
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def match_company name
    @company_matcher ||= {}
    @company_matcher[name] ||= CompanyMatcher.new(name)
  end

  def company_correction_field row_hash
    text_field_tag("corrected_company_name[#{row_hash[:row]}]", "",
                   class: "company_autocomplete")
  end

  def prepare_import_checkbox row_hash
    checked = %w[partial exact alias].include? row_hash[:status]
    key_hash = row_hash.deep_dup
    key_hash[:company] =
      if row_hash[:match].none?
        row_hash[:file_company]
      else
        row_hash[:wikirate_company]
      end
    [key_hash, checked]
  end

  def import_checkbox row_hash
    key_hash, checked = prepare_import_checkbox row_hash
    check_box_tag "import_data[]", key_hash.to_json, checked
  end

  def data_correction data
    return "" if data[:match].exact?
    company_correction_field data
  end

  def prepare_and_sort_rows rows, _args
    rows.map.with_index do |row, index|
      prepare_import_row_data row, index + 1
    end.sort do |a, b|
      a[:match] <=> b[:match]
    end
  end

  def prepare_import_row_data row, index
    data = row_to_hash row
    data[:csv_row_index] = index
    data[:match] = match_company data[:file_company]
    data[:wikirate_company], data[:status] = data[:match].match
    data[:company] = data[:match].suggestion
    data
  end

  def finalize_row row, index
    row[:row] = index
    row[:checkbox] = import_checkbox row
    row[:correction] = data_correction row
    row
  end

  def import_table_row row, table_fields, index
    row = finalize_row row, index
    content =
      table_fields.map { |key| row[key].to_s }
    { content: content,
      class: "table-#{row_context(row[:status])}",
      data: { csv_row_index: row[:csv_row_index] } }
  end

  def row_context status
    case status
    when :partial then "warning"
    when :exact   then "success"
    when :none    then "danger"
    when :alias   then "info"
    end
  end

  def row_to_hash row
    import_fields.each_with_object({}).with_index do |(key, hash), i|
      hash[key] = row[i]
      hash[key] &&= hash[key].force_encoding "utf-8"
    end
  end

  def duplicated_value_warning_message headline, cardnames
    items = cardnames.map { |n| "<li>#{n}</li>" }.join
    alert("warning") { "<h4>#{headline}</h4><ul>#{items}</ul>" }
  end
end
