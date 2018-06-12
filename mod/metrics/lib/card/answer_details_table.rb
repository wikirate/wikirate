class Card
  # Renders the table with details of a metric answer.
  # It delegate the rendering depending on the metric type to another class.
  class AnswerDetailsTable
    # @param format [Card::Format] the format of a card of
    #    cardtype "metric value" (=answer)
    def initialize format
      metric_type = format.card.metric_card.metric_type_codename.to_s.capitalize
      table_class = Card.const_get "#{metric_type}AnswerDetailsTable"
      @table = table_class.new format
    end

    def render
      @table.render
    end
  end
end
