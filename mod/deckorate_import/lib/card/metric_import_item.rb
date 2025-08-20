class Card
  # create a metric described by a row in a csv file
  class MetricImportItem < ImportItem
    @columns = {
      question: { optional: true },
      metric_type: {}, # { map: true, type: :metric_type_type },

      # Metric Name Parts
      metric_designer: {}, # TODO: map when we support multi-type mapping
      metric_title: {},
      scorer: { optional: true },

      formula: { optional: true },
      variables: { optional: true },
      rubric: { optional: true },

      topic: { optional: true, map: true, separator: ";" },
      unpublished: { optional: true },

      # Rich-Text fields
      about: { optional: true },
      methodology: { optional: true },
      # Note: special html is added for certain content, eg
      #       "Note:" and "Sources:" are made bold

      value_type: {},
      unit: { optional: true },
      range: { optional: true },
      hybrid: { optional: true },
      inverse_title: { optional: true },

      value_options: { optional: true, separator: ";" },
      report_type: { map: true, optional: true, separator: ";" },
      assessment: { map: true, separator: ";" },

      year: { optional: true, separator: ";" },
      company_group: { optional: true, separator: ";" }
    }

    VALUE_TYPE_CORRECTIONS = { "categorical" => :category.cardname }.freeze

    # @normalize = { topic: :comma_list_to_pointer }

    # FIXME: this currently drops unknown topics.
    # def normalize_topic value
    #   topics = value.split(";").map(&:strip)
    #   topics = topics.select { |t| Card[t]&.type_id == Card::TopicID }
    #   topics.to_pointer_content
    # end

    def normalize_unpublished val
      val.to_s.downcase.in?(%w[1 true t yes y]) ? "1" : "0"
    end

    def normalize_value_type value
      value = value.to_name
      if valid_value_type? value
        value.standard
      elsif (correction = VALUE_TYPE_CORRECTIONS[value.key])
        correction
      else
        value
      end
    end

    def validate_metric_type value
      Card.fetch_type_id(value) == Card::MetricTypeTypeID
    end

    def valid_value_type? value
      value_type_codes.include? value&.to_name&.codename
    end

    def normalize_methodology value
      return value unless value.present?
      format_html to_html(value)
    end

    def normalize_about value
      return value unless value.present?
      format_html to_html(value)
    end

    def import_hash
      i = input.clone
      {
        name: metric_name(i),
        type_id: Card::MetricID,
        fields: prep_fields(i)
      }
    end

    private

    def to_html value
      value.gsub "\n", "<br>\n"
    end

    def metric_name r
      name_parts = [r.delete(:metric_designer), r.delete(:metric_title)]
      scorer = r.delete(:scorer)
      name_parts << scorer if scorer.present?
      Card::Name[name_parts]
    end

    def value_type_codes
      Card::Set::TypePlusRight::Metric::ValueType::VALUE_TYPE_CODES
    end

    def format_html html
      html.gsub(/\b(OR|AND)\b/, "<strong>\\1</strong>")
          .gsub(/Note:([^<]+)<br>/, "<em><strong>Note:</strong>\\1</em><br>")
          .gsub(/<p>([^<]+)<br>/, "<p><strong>\\1</strong><br>")
          .gsub("Sources:", "<strong>Sources:</strong>")

      #        .gsub(/(<br><br>|^)([^<]+)(?=<br>)/) do |m|
      #      m.split(" ").size > 15 ? "#{m[1]}#{m[2]}" : "#{m[1]}<strong>#{m[2]}</strong>"
      #    end
    end
  end
end
