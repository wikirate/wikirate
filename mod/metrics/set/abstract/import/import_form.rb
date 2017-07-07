format :html do
  def default_new_args args
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

  def reject_header_row import_data
    return unless (first_row = import_data.first)
    return unless includes_column_header first_row
    import_data.shift
  end

  def includes_column_header row
    headers = import_fields
    headers << :company
    row.any? { |item| item && headers.include?(item.downcase.to_sym) }
  end

  def aliases_hash
    @aliases_hash ||= begin
      aliases_cards = Card.search right: "aliases",
                                  left: { type_id: WikirateCompanyID }
      aliases_cards.each_with_object({}) do |aliases_card, aliases_hash|
        aliases_card.item_names.each do |name|
          aliases_hash[name.downcase] = aliases_card.cardname.left
        end
      end
    end
  end

  def company_mapper
    @mapper ||=
      begin
        corpus = Company::Mapping::CompanyCorpus.new
        Card.search(type_id: WikirateCompanyID, return: :id).each do |company_id|
          company_name = Card.fetch_name(company_id)
          aliases = (a_card = Card[company_name, :aliases]) && a_card.item_names
          corpus.add company_id, company_name, (aliases || [])
        end
        Company::Mapping::CompanyMapper.new corpus
      end
  end

  def map_company name
    id = company_mapper.map(name, COMPANY_MAPPER_THRESHOLD)
    Card.fetch_name id
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def matched_company name
    @company_map ||= {}
    @company_map[name] ||=
      if (company = Card.fetch(name)) && company.type_id == WikirateCompanyID
        [name, :exact]
      elsif (company_name = aliases_hash[name.downcase])
        [company_name, :alias]
      elsif (result = map_company(name))
        [result, :partial]
      else
        ["", :none]
      end
  end

  def company_correction_field row_hash
    text_field_tag("corrected_company_name[#{row_hash[:row]}]", "",
                   class: "company_autocomplete")
  end

  def prepare_import_checkbox row_hash
    checked = %w[partial exact alias].include? row_hash[:status]
    key_hash = row_hash.deep_dup
    key_hash[:company] =
      if row_hash[:status] == "none"
        row_hash[:file_company]
      else
        row_hash[:wikirate_company]
      end
    [key_hash, checked]
  end

  def import_checkbox row_hash
    key_hash, checked = prepare_import_checkbox row_hash
    tag = check_box_tag "import_data[]", key_hash.to_json, checked
    tag
  end

  def data_correction data
    if data[:status] == "exact"
      ""
    else
      company_correction_field data
    end
  end

  def data_company data
    if data[:wikirate_company].empty?
      data[:file_company]
    else
      data[:wikirate_company]
    end
  end

  def find_wikirate_company file_company
    if file_company.present?
      matched_company file_company
    else
      ["", :none]
    end
  end

  def prepare_and_sort_rows rows, _args
    rows.map.with_index do |row, index|
      prepare_import_row_data row, index + 1
    end.sort do |a, b|
      compare_status a, b
    end
  end

  def prepare_import_row_data row, index
    data = row_to_hash row
    data[:csv_row_index] = index
    data[:wikirate_company], data[:status] = find_wikirate_company data[:file_company]
    data[:status] = data[:status].to_s
    data[:company] = data_company data
    data
  end

  def compare_status a, b
    a = STATUS_ORDER[a[:status].to_sym] || 0
    b = STATUS_ORDER[b[:status].to_sym] || 0
    a <=> b
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
      class: row_context(row[:status]),
      data: { csv_row_index: row[:csv_row_index] } }
  end

  def row_context status
    case status
    when "partial" then "warning"
    when "exact"   then "success"
    when "none"    then "danger"
    when "alias"   then "info"
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
