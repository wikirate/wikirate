class Card
  class AnswerDetailsTable
    # @param format [Card::Format] the format of a card of
    #    cardtype "metric value" (=answer)
    def initialize format
      table_class =
        case format.card.metric_card.metric_type_code
        when :score
          ScoreAnswerDetailsTable
        when :formula
          FormulAnswerDetailsTable
        else
          WikiratingAnswerDetailsTable
        end

      @table = table_class.new(format)
    end

    def render
      @table.render
    end
  end
end
