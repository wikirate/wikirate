require_relative "../../../vendor/card-mods/csv_import/lib/csv_row.rb"
require_relative "../../../vendor/card-mods/csv_import/lib/csv_file.rb"

# create a metric described by a row in a csv file
class MetricCsvRow < CsvRow
  @columns =
    [:metric_designer, :metric_title, # parts of metric name
     :question,
     :about, :methodology, # special html is added for certain content, eg
     #                       "Note:" and "Sources:" are made bold
     :topic,               # comma separated

     :value_type,          # examples:
     #                         Free Text
     #                         Number (tons)
     #                         Category (option1;option2)
     #     :value_options,
     :research_policy,     # supports "community", "designer", or full name,
     #                       eg "Community Assessed"
     :metric_type,
     :report_type]

  @required = [:metric_designer, :metric_title, :value_type, :metric_type]
  # @normalize = { topic: :comma_list_to_pointer }

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

  def normalize_topic value
    topics = value.split(",").map(&:strip)
    topics = topics.select { |t| Card[t]&.type_id == Card::WikirateTopicID }
    topics.to_pointer_content
  end

  def normalize_value_type value
    @value_details ||= {}
    value.match(/(?<type>[^(]+)\((?<options>.+)\)$/) do |match|
      new_value = match[:type].strip
      new_value = "Category" if new_value == "Categorical"
      if new_value.downcase.in? %w[category multi-category]
        @value_details[:value_options] = comma_list_to_pointer match[:options], ";"
      else
        @value_details[:unit] = match[:options].strip
      end
      new_value
    end
  end

  def format_html html
    html.gsub(/\b(OR|AND)\b/, "<strong>\\1</strong>")
        .gsub(/Note:([^<]+)<br>/, "<em><strong>Note:</strong>\\1</em><br>")
        .gsub(/<p>([^<]+)<br>/, "<p><strong>\\1</strong><br>")
        .gsub("Sources:", "<strong>Sources:</strong>")
        .gsub(/(<br><br>|^)([^<]+)(?=<br>)/) do |m|
      m.split(" ").size > 15 ? "#{$1}#{$2}" : "#{$1}<strong>#{$2}</strong>"
    end
  end

  def normalize_methodology value
    return value unless value.present?
    format_html to_html(value)
  end

  def normalize_about value
    return value unless value.present?
    format_html to_html(value)
  end

  def normalize_metric_type value
    return value unless value =~ /research/i
    "Researched"
  end

  def normalize_value_options value
    comma_list_to_pointer value, ";"
  end

  def import
    @designer = @row.delete :metric_designer
    @title = @row.delete(:metric_title).gsub("/", "&#47;")
    @name = "#{@designer}+#{@title}"
    @row[:wikirate_topic] = @row.delete :topic if @row[:topic]
    create_card @designer, type: Card::ResearchGroupID unless Card.exists?(@designer)
    create_card @title, type: Card::MetricTitleID unless Card.exists?(@title)
    ensure_card @name, type: Card::MetricID, subfields: subfields
  end

  def subfields
    @row.select { |_k, v| v.present? }
  end
end
