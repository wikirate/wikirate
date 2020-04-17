require_relative "../../../vendor/card-mods/csv_import/lib/import_item.rb"
require_relative "../../../vendor/card-mods/csv_import/lib/csv_file.rb"

# create a metric described by a row in a csv file
class MetricImportItem < ImportItem
  @columns = {
    question: { optional: true },
    metric_type: {}, #{ map: true, type: :metric_type_type },

    # Metric Name Parts
    metric_designer: {}, # TODO: map when we support multi-type mapping
    metric_title: {},

    topic: { optional: true},
    # TODO: map when we support (optional) multi-value mapping

    # Rich-Text fields
    about: { optional: true },
    methodology: { optional: true },
    # Note: special html is added for certain content, eg
    #       "Note:" and "Sources:" are made bold

    value_type: {},

    value_options: { optional: true },
    research_policy: { optional: true },
    # supports "community", "designer", or full name, eg "Community Assessed"
    report_type: { optional: true }

    # TODO: map research policy, report_type when we support mapping optional fields
  }

  VALUE_TYPE_CORRECTIONS = { "categorical" => :category.cardname }

  #@normalize = { topic: :comma_list_to_pointer }

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

  # FIXME: this currently drops unknown topics.
  def normalize_topic value
    topics = value.split(";").map(&:strip)
    topics = topics.select { |t| Card[t]&.type_id == Card::WikirateTopicID }
    topics.to_pointer_content
  end

  def normalize_value_type value
    value = value.to_name
    if validate_value_type value
      Card.fetch_name value
    elsif correction = VALUE_TYPE_CORRECTIONS[value.key]
      correction
    else
      value
    end
  end

  def validate_metric_type value
    Card.fetch_type_id(value) == Card::MetricTypeTypeID
  end

  def validate_value_type value
    value_type_codes.include? value&.to_name&.code
  end

  def normalize_methodology value
    return value unless value.present?
    format_html to_html(value)
  end

  def normalize_about value
    return value unless value.present?
    format_html to_html(value)
  end

  def normalize_value_options value
    comma_list_to_pointer value, ";"
  end

  def import_hash
    r = @row.clone
    r[:wikirate_topic] = r.delete(:topic)
    {
      name: Card::Name[r.delete(:metric_designer),
                       r.delete(:metric_title).gsub("/", "&#47;")],
      type_id: Card::MetricID,
      subfields: r.select { |_k, v| v.present? }
    }
  end

  private

  def value_type_codes
    Card::Set::TypePlusRight::Metric::ValueType::VALUE_TYPE_CODES
  end

  def format_html html
    html.gsub(/\b(OR|AND)\b/, "<strong>\\1</strong>")
      .gsub(/Note:([^<]+)<br>/, "<em><strong>Note:</strong>\\1</em><br>")
      .gsub(/<p>([^<]+)<br>/, "<p><strong>\\1</strong><br>")
      .gsub("Sources:", "<strong>Sources:</strong>")
      .gsub(/(<br><br>|^)([^<]+)(?=<br>)/) do |m|
      m.split(" ").size > 15 ? "#{m[1]}#{m[2]}" : "#{m[1]}<strong>#{m[2]}</strong>"
    end
  end
end
