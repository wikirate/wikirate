require_relative "csv_row"

# create a metric answer described by a row in a csv file
class MetricAnswerCSVRow < CSVRow
  @columns =
    [:metric, :company, :year, :value, :source, :comment]

  @required = :all

  def initialize row, index, corrections=nil, extra_data=nil
    @file_company = row[:company]
    super # overrides company with correction

    case (@match_type = @extra_data[:match_type].to_sym)
    when :alias
      @row[:company] = suggested_company
    when :partial
      @row[:company] = @corrections[:company] || suggested_company
    when :none
      @row[:company] = @corrections[:company] if user_corrected_company?
    end
  end

  def import
    create_card @designer, type: Card::ResearchGroupID unless Card.exists?(@designer)
  end

  def import_as_subcard card
    process_source args, source_map
    return unless valid_value_data? args
    return unless ensure_company_exists args[:company], args
    return unless (create_args = construct_value_args args)
    check_duplication_in_subcards create_args[:name], args[:row]
    return if check_duplication_with_existing create_args[:name], args[:source]
    card.add_subcard create_args.delete(:name), create_args
  end

  def add_alias
    return if @match_type == :exact || @match_type == :alias
    unless Card.exists?(@company)
      Card.create! name: @company, type_id: WikirateCompanyID
    end

    if user_corrected_company? || @match_type == :partial
      Card[@company].add_alias @file_company
    end
  end

  def suggested_company
    @extra_data[:suggestion]
  end

  def user_corrected_company?
    @corrections[:company].present?
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

  def check_if_filled_in field, args, field_name=nil
    return if args[field.to_sym].present?
    field_name ||= field
    add_import_error "#{field_name} missing"
  end

  def check_existence_and_type name, type_id, type_name=nil
    if !Card[name]
      add_import_error "#{name} doesn't exist"
    elsif Card[name].type_id != type_id
      add_import_error "#{name} is not a #{type_name}"
    end
  end

  def check_duplication_in_subcards name, row_no
    return unless subcards[name]
    errors.add "Row #{row_no}:#{name}", "Duplicated metric values"
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
end
