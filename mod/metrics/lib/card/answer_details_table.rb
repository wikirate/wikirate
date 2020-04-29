class Card
  # Renders the table with details of a metric answer.
  # It delegate the rendering depending on the metric type to another class.
  class AnswerDetailsTable
    # @param format [Card::Format] the format of a card of
    #    cardtype "metric value" (=answer)
    def initialize format
      @format = format
      @table = table_class.new format
    end

    def metric_card
      @metric_card ||= @format.card.metric_card
    end

    def metric_type
      @metric_type ||= metric_card.metric_type_codename
    end

    def table_class
      Card.const_get "#{table_class_base}AnswerDetailsTable"
    end

    def table_class_base
      metric_type == :score ? score_table_class_base : metric_type.to_s.camelize
    end

    def score_table_class_base
      metric_card.categorical? ? "CategoryScore" : "FormulaScore"
    end

    def render
      @table.render
    end
  end
end
