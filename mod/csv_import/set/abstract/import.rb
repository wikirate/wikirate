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

def clean_html?
  false
end
