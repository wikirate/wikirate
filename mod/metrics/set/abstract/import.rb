COMPANY_MAPPER_THRESHOLD = 0.5

STATUS_ORDER = { none: 1, partial: 2, alias: 3, exact: 4 }

# the is_data_import flag distinguishes between an update of the
# import file and importing the file
event :import_csv, :prepare_to_store, on: :update, when: :data_import? do
  return unless (import_data = Env.params[:import_data])
  return unless valid_import_format?(import_data)
  source_map = {}
  init_success_params
  import_data.each do |import_row|
    import_card = parse_import_row import_row, source_map
    # validate value type
    if import_card
      import_card.director.catch_up_to_stage :validate
      import_card.director.transact_in_stage = :integrate
    end
    handle_import_errors import_card
  end
  clear_success_params
  handle_redirect
end

def data_import?
  Env.params["is_data_import"] == "true"
end

def success_params
  [:identical_metric_value, :duplicated_metric_value]
end

def init_success_params
  success_params.each { |key| success.params[key] = [] }
end

def clear_success_params
  success_params.each do |key|
    success.params.delete(key) unless success[key].present?
  end
end

def check_duplication_in_subcards name, row_no
  return unless subcards[name]
  errors.add "Row #{row_no}:#{name}", "Duplicated metric values"
end

def metric_value_args_error_key key, args
  "Row #{args[:row]}:#{args[:metric]}+#{args[:company]}+#{args[:year]}+#{key}"
end

def construct_value_args args
  unless (create_args = Card[args[:metric]].create_value_args args)
    Card[args[:metric]].errors.each do |key, value|
      errors.add metric_value_args_error_key(key, args), value
    end
    # clear old errors
    Card[args[:metric]].errors.clear
    return nil
  end
  create_args
end

def check_duplication_with_existing metric_value_name, source_card
  return false unless (source = Card[metric_value_name.to_name.field(:source)])
  bucket =
    source.item_cards[0].key == source_card.key ? :identical : :duplicated
  success.params["#{bucket}_metric_value".to_sym].push metric_value_name
  true
end

# @return updated or created metric value card object
def parse_import_row import_data, source_map
  args = process_data import_data
  process_source args, source_map
  return unless valid_value_data? args
  return unless ensure_company_exists args[:company], args
  return unless (create_args = construct_value_args args)
  check_duplication_in_subcards create_args[:name], args[:row]
  return if check_duplication_with_existing create_args[:name], args[:source]
  add_subcard create_args.delete(:name), create_args
end

def source_args url
  {
    "+*source_type" => { content: "[[Link]]" },
    "+Link" => { content: url, type_id: PhraseID }
  }
end

def finalize_source_card source_card
  Env.params[:sourcebox] = "true"
  source_card.director.catch_up_to_stage :prepare_to_store
  if !Card.exists?(source_card.name) && source_card.errors.empty?
    source_card.director.catch_up_to_stage :finalize
  end
  Env.params[:sourcebox] = nil
end

def create_source url
  source_card = add_subcard "", type_id: SourceID, subcards: source_args(url)
  finalize_source_card source_card
  unless source_card.errors.empty?
    source_card.errors.each { |k, v| errors.add k, v }
  end
  source_card
end

def process_source metric_value_data, source_map
  url = metric_value_data[:source]
  if (source_card = source_map[url])
    metric_value_data[:source] = source_card
    return
  end
  duplicates = Self::Source.find_duplicates url
  source_card =
    if duplicates.any?
      duplicates.first.left
    else
      create_source url
    end
  metric_value_data[:source] = source_card
  source_map[url] = source_card
end

# @return [Hash] args to create metric value card
def process_data metric_value_data
  mv_hash = if metric_value_data.is_a? Hash
              metric_value_data
            else
              JSON.parse(metric_value_data).symbolize_keys
            end
  mv_hash[:company] = get_corrected_company_name mv_hash
  mv_hash
end

def valid_import_format? data
  data.is_a? Array
end

def redirect_target_after_import
  nil
end

def company_corrections
  @company_corrections ||=
    begin
      hash = Env.params[:corrected_company_name]
      return {} unless hash.is_a?(Hash)
      hash.delete_if { |_k, v| v.blank? }
    end
end

def handle_redirect
  if errors.empty?
    if (target = redirect_target_after_import)
      success << { name: target, redirect: true, view: :open }
    end
  else
    abort :failure
  end
end

def handle_import_errors metric_value_card
  @import_errors.each do |msg|
    errors.add(*msg)
  end
  return unless metric_value_card
  metric_value_card.errors.each do |key, error_value|
    errors.add "#{metric_value_card.name}+#{key}", error_value
  end
end

def get_corrected_company_name params
  corrected = company_corrections[params[:row].to_s]
  if corrected.blank?
    if params[:status] && params[:status].to_sym == :partial &&
       (original = Card[params[:wikirate_company]])
      original.add_alias params[:file_company]
    end
    return params[:company] unless corrected.present?
  end
  unless Card.exists?(corrected)
    Card.create! name: corrected, type_id: WikirateCompanyID
  end
  if corrected != params[:file_company]
    Card[corrected].add_alias params[:file_company]
  end
  corrected
end

def valid_value_data? args
  collect_import_errors(args[:row]) do
    check_if_filled_in :metric, args, "metric name"
    %w[company year value].each { |field| check_if_filled_in field, args }
    { metric: MetricID, year: YearID }.each_pair do |type, type_id|
      check_existence_and_type args[type], type_id, type
    end
  end
end

def collect_import_errors row
  @import_errors = []
  @current_row = row
  yield
  @current_row = nil
  @import_errors.empty?
end

def check_if_filled_in field, args, field_name=nil
  return if args[field.to_sym].present?
  field_name ||= field
  add_import_error "#{field_name} missing"
end

def add_import_error msg, row=@current_row
  return unless msg
  title = "import error"
  title += " (row #{row})" if row
  @import_errors << [title, msg]
end

def check_existence_and_type name, type_id, type_name=nil
  if !Card[name]
    add_import_error "#{name} doesn't exist"
  elsif Card[name].type_id != type_id
    add_import_error "#{name} is not a #{type_name}"
  end
end

def ensure_company_exists company, args
  if Card.exists?(company)
    return true if Card[company].type_id == WikirateCompanyID
    msg = "#{company} is not a company"
    add_import_error msg, args[:row]
  else
    add_subcard company, type_id: WikirateCompanyID
  end
  @import_errors.empty?
end

def csv_rows
  CSV.parse file.read, encoding: "utf-8"
rescue ArgumentError
  # if parsing with utf-8 encoding fails, assume it's iso-8859-1 encoding
  # and convert to utf-8
  CSV.parse file.read, encoding: "iso-8859-1:utf-8"
end

def clean_html? # return always true ;)
  false
end

format :html do
  def import_fields
    [:file_company, :value]
  end

  def new_view_hidden
    hidden_tags success: { id: "_self", soft_redirect: false, view: :import }
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

  def find_wikirate_company data
    if data[:file_company].present?
      matched_company data[:file_company]
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
    data[:wikirate_company], data[:status] = find_wikirate_company data
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
      hask[key] &&= hash[key].force_encoding "utf-8"
    end
  end

  def duplicated_value_warning_message headline, cardnames
    items = cardnames.map { |n| "<li>#{n}</li>" }.join
    alert("warning") { "<h4>#{headline}</h4><ul>#{items}</ul>" }
  end
end
