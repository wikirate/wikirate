class Card
  # converts specifications into a SubjConstraint object
  class SubjConstraint
    attr_accessor :metric, :year, :value, :group

    def self.new_from_raw raw_constraint
      new(*CSV.parse_line(raw_constraint))
    end

    def initialize metric, year, value=nil, group=nil
      @metric = Card.cardish metric
      @year = year.to_s
      @value = interpret_value value
      @group = Card.cardish(group) if group.present?
    end

    def interpret_value value
      if value.is_a? String
        parsed = JSON.parse value
        parsed.is_a?(Hash) ? parsed.symbolize_keys : parsed
      else
        value
      end
    end

    def to_s row_sep=nil
      ["[[#{metric.name}]]", year, value.to_json, group].to_csv(row_sep: row_sep)
    end

    def validate!
      raise "invalid metric" unless valid_metric?
      raise "invalid year" unless valid_year?
    end

    def valid_metric?
      metric&.type_id == Card::MetricID
    end

    def valid_year?
      year.match(/^\d{4}$/) || year.in?(%w[any latest])
    end

    def query_hash
      h = { metric_id: metric.id, value: value, related_company_group: group }
      h[:year] = year unless year == "any"
      h
    end

    def conditions
      AnswerQuery.new(query_hash).lookup_conditions
    end
  end
end
