require_relative "../../csv_import/csv_row"

class MetricCSVRow < CSVRow
  @required = [:metric_designer, :metric_title, :value_type]

  @normalize = { topics: :comma_list_to_pointer,
                 value_type: :process_value_type }

  def initialize row
    super
    @designer = @row.delete :metric_designer
    @title = @row.delete :metric_title
    @name = "#{@designer}+#{@title}"
    @row[:wikirate_topic] = @row.delete :topics if @row[:topics]
    @row[:value_options] = @value_options if @value_options
    @row[:unit] = @unit if @unit
  end

  def comma_list_to_pointer str
    str.split(',').map(&:strip).to_pointer_content
  end

  def process_value_type value
    value.match /(?<type>[^(]+)\((?<options>[^)]+)/ do |match|
      new_value = match[:type].strip
      if new_value == "Category"
        @value_options = comma_list_to_pointer match[:options]
      else
        @unit = match[:options].strip
      end
      new_value
    end
  end

  def create
    create_card @designer, type: Card::ResearchGroupID unless Card.exists?(@designer)
    create_card @title, type: Card::MetricTitleID unless Card.exists?(@title)
    create_card @name, type: Card::MetricID, subfields: @row
  end
end
