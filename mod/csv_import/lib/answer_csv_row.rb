require_relative "csv_row"
require_relative "csv_row/source_import"

# create a metric answer described by a row in a csv file
class AnswerCSVRow < CSVRow
  include CSVRow::SourceImport
  include CSVRow::CompanyImport

  @columns =
    [:metric, :company, :year, :value, :source, :comment]

  @required = [:metric, :company, :year, :value, :source]

  def initialize row, index, import_manager=nil
    super
    # use only the source value for creating the source
    # TODO: consider to add company to source args
    @source_args = { source: @row[:source] }
  end

  def import
    import_manager.with_conflict_strategy :skip_card do
      @row[:source] = import_source update_existing: false
      import_company
    end
    build_answer_create_args
    # TODO: decide what to do with this duplications check
    #check_for_duplicates
    throw :skip_row, :failed if errors.any?
    import_card answer_create_args
  end

  def validate_metric metric
    check_existence_and_type metric, Card::MetricID, "metric"
    true
  end

  def validate_year year
    check_existence_and_type year, Card::YearID, "year"
    true
  end

  private

  def check_for_duplicates
    # TODO: handle return value of check_duplication_with_existing
    check_duplication_with_existing
  end

  def build_answer_create_args
    @answer_create_args = construct_answer_create_args
  end

  def answer_create_args
    @answer_create_args ||= construct_answer_create_args
  end

  def check_existence_and_type name, type_id, type_name=nil
    if !Card.exists?(name)
      error "\"#{name}\" doesn't exist"
    elsif Card[name].type_id != type_id
      error "\"#{name}\" is not a #{type_name}"
    end
  end

  def answer_name
    answer_create_args[:name]
  end

  def resolve_source_duplicates existing_source_card
    existing_source_card
  end

  def check_duplication_with_existing
    return unless (source = Card[answer_name, :source])
    bucket =
      source.item_cards[0].key == @raw[:source].key ? :identical : :duplicated
    #throw :skip_row
    success.params["#{bucket}_answer".to_sym].push [@row_index, answer_name]
  end

  def construct_answer_create_args
    create_args = Card[metric].create_value_args @row
    pick_up_card_errors Card[metric]
    create_args
  end
end
