# the is_data_import flag distinguishes between an update of the
# import file and importing the file
event :import_csv, :prepare_to_store,
      on: :update,
      when: proc { Env.params["is_data_import"] == "true" } do
  return unless (import_data = Env.params[:import_data])
  return unless valid_import_format?(import_data)
  source_map = {}
  init_success_slot_params
  import_data.each do |import_row|
    import_card = parse_import_row import_row, source_map
    # validate value type
    if import_card
      import_card.director.catch_up_to_stage :validate
      import_card.director.transact_in_stage = :integrate
    end
    handle_import_errors import_card
  end
  clear_slot_params
  handle_redirect
end


def init_success_slot_params
  success.params[:slot] = {
    identical_metric_value: [],
    duplicated_metric_value: []
  }
end

def clear_slot_params
  slot_args = success.params[:slot]
  slot_args.each do |key, value|
    slot_args.delete(key) unless value.present?
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
  slot_args = success.slot
  if (source = Card[metric_value_name.to_name.field(:source)])
    if source.item_cards[0].key == source_card.key
      slot_args[:identical_metric_value].push(metric_value_name)
    else
      slot_args[:duplicated_metric_value].push(metric_value_name)
    end
    return true
  end
  false
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
  return params[:company] unless corrected.present?

  unless Card.exists?(corrected)
    Card.create! name: corrected, type_id: WikirateCompanyID
  end
  Card[corrected].add_alias params[:company] if corrected != params[:company]
  corrected
end

def valid_value_data? args
  collect_import_errors(args[:row]) do
    check_if_filled_in :metric, args, "metric name"
    %w(company year value).each { |field| check_if_filled_in field, args }
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
    msg = "#{company} is not in company type"
    add_import_error msg, args[:row]
  else
    add_subcard company, type_id: WikirateCompanyID
  end
  @import_errors.empty?
end

def csv_rows
  # transcode to utf8 before CSV reads it.
  # some users upload files in non utf8 encoding.
  # The microsoft excel may not save a CSV file in utf8 encoding
  CSV.read(file.path, encoding: "windows-1251:utf-8")
end

def clean_html? # return always true ;)
  false
end

format :html do
  def import_fields
    [:file_company, :value]
  end

  def default_new_args args
    args[:hidden] = {
      success: { id: "_self", soft_redirect: false, view: :import }
    }
    super args
  end

  def default_import_args args
    args[:buttons] = %(
      #{button_tag 'Import', class: 'submit-button',
                             data: { disable_with: 'Importing' }}
      #{button_tag 'Cancel', class: 'cancel-button slotter', href: path,
                             type: 'button'}
    )
  end

  view :import do |args|
    success_args = { success: { id: "_self", view: :open } }
    frame_and_form :update, "notify-success" => "import successful" do
      [
        _optional_render(:metric_select, args),
        _optional_render(:year_select, args),
        _optional_render(:import_flag, args),
        _optional_render(:import_table_helper, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :year_select do |_args|
    nest card.left.year_card, view: :edit_in_form
  end

  view :metric_select do |_args|
    nest card.left.metric_card, view: :edit_in_form
  end

  view :import_flag do |_args|
    hidden_field_tag :is_data_import, "true"
  end

  view :import_table_helper do |_args|
    content_tag(:p, selection_checkbox + import_legend)
  end

  def selection_checkbox
    <<-HTML.html_safe
      #{check_box_tag 'uncheck_all', '', false, class: 'checkbox-button'}
      #{label_tag 'Uncheck All'}
      #{check_box_tag 'partial', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Partial'}
      #{check_box_tag 'exact', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Exact'}
    HTML
  end

  def import_legend
    <<-HTML.html_safe
     <span class="pull-right">
      company match:
      #{row_legend "exact", "success"}
      #{row_legend "alias", "info"}
      #{row_legend "partial", "warning"}
      #{row_legend "none", "danger"}
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
    content_tag :span, text, opts
  end

  def default_import_table_args args
    args[:table_header] = ["Import", "#", "Company in File",
                           "Company in Wikirate", "Correction"]
    args[:table_fields] = [:checkbox, :row, :file_company, :wikirate_company,
                           :correction]
  end

  view :import_table do |args|
    data = card.csv_rows
    reject_header_row data
    data = data.map.with_index do |elem, i|
      import_row(elem, args[:table_fields], i + 1)
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

  def get_potential_company name
    result = Card.search type: "company", name: ["match", name]
    # do not match companies less than 4 characters
    result.reject { |r| r.name.length <= 4 }
    return nil if result.empty?
    result
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def matched_company name
    if (company = Card.fetch(name)) && company.type_id == WikirateCompanyID
      [name, :exact]
      # elsif (result = Card.search :right=>"aliases",
      # :left=>{:type_id=>Card::WikirateCompanyID},
      # :content=>["match","\\[\\[#{name}\\]\\]"]) && !result.empty?
      #   [result.first.cardname.left, :alias]
    elsif (company_name = aliases_hash[name.downcase])
      [company_name, :alias]
    elsif (result = get_potential_company(name))
      [result.first.name, :partial]
    elsif (company_name = part_of_company(name))
      [company_name, :partial]
    else
      ["", :none]
    end
  end

  def part_of_company name
    Card.search(type: "company", return: "name").each do |comp|
      return comp if name.match comp
    end
    nil
  end

  def company_correction_field row_hash
    text_field_tag("corrected_company_name[#{row_hash[:row]}]", "",
                   class: "company_autocomplete")
  end

  def prepare_import_checkbox row_hash
    checked = %w(partial exact alias).include? row_hash[:status]
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
    check_box_tag "import_data[]", key_hash.to_json, checked
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

  def prepare_import_row_data row, index
    data = row_to_hash row
    data[:row] = index
    data[:wikirate_company], data[:status] = find_wikirate_company data
    data[:status] = data[:status].to_s
    data[:company] = data_company data
    data[:checkbox] = import_checkbox data
    data[:correction] = data_correction data
    data
  end

  def import_row row, table_fields, index
    data = prepare_import_row_data row, index
    content = table_fields.map { |key| data[key].to_s }
    { content: content,
      class: row_context(data[:status]) }
  end

  def row_context status
    case status
    when "partial" then "warning"
    when "exact" then "success"
    when "none" then "danger"
    when "alias" then "info"
    end
  end

  def row_to_hash row
    import_fields.each_with_object({}).with_index do |(key, hash), i|
      hash[key] = row[i]
    end
  end

  def duplicated_value_warning_message headline, cardnames
    msg = <<-HTML
      <h4><b>#{headline}</b></h4>
      <ul><li>#{cardnames.join('</li><li>')}</li> <br />
    HTML
    alert("warning") { msg }
  end
end
