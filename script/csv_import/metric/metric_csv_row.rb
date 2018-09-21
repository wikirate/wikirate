require_relative "../csv_row"

# create a metric described by a row in a csv file
class MetricCSVRow < CSVRow
  @columns =
    [:metric_designer, :metric_title, :question, :about, :methodology,
     :topics, :value_type, :research_policy, :metric_type, :report_type]

  @required = [:metric_designer, :metric_title, :value_type, :metric_type]
  @normalize = { topics: :comma_list_to_pointer,
                 about: :to_html,
                 methodology: :to_html }

  def initialize row
    @value_details = {}
    super
    @designer = @row.delete :metric_designer
    @title = @row.delete(:metric_title).gsub("/", "&#47;")
    @name = "#{@designer}+#{@title}"
    @row[:wikirate_topic] = @row.delete :topics if @row[:topics]
  end

  def normalize_research_policy value
    policy =
      case value
      when /community/i
        "Community Assessed"
      when /designer/i
        "Designer Assessed"
      else
        value
      end
    @row[:research_policy] = { content: policy, type_id: Card::PointerID }
  end

  def normalize_value_type value
    value.match(/(?<type>[^(]+)\((?<options>[^)]+)/) do |match|
      new_value = match[:type].strip
      new_value = "Category" if new_value == "Categorical"
      if new_value == "Category" || new_value == "Multi-Category"
        @value_details[:value_options] = comma_list_to_pointer match[:options]
      else
        @value_details[:unit] = match[:options].strip
      end
      new_value
    end
  end

  def import
    create_card @designer, type: Card::ResearchGroupID unless Card.exists?(@designer)
    create_card @title, type: Card::MetricTitleID unless Card.exists?(@title)
    ensure_card @name, type: Card::MetricID, subfields: @row.merge(@value_details)
  end
end
