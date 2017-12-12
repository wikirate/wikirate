class Card
  class AnswerDetailsTable
    cattr_accessor :columns

    # @param format [Card::Format] the format of a card of
    #    cardtype "metric value" (=answer)
    def initialize format
      @format = format
    end

    def columns
      self.class.columns
    end

    def render
      @format.table table_rows, header: columns
    end

    private

    def metric_row input_card
      v_card = value_card input_card
      return unless v_card
      [metric_thumbnail(input_card), raw_value(v_card), colorify(score_value(v_card))]
    end

    def company
      @format.card.company_name
    end

    def year
      @format.card.year
    end

    def value_card input_card
      # wql = input_card.metric_value_query
      # wql[:left][:right] = company
      # wql[:right] = year
      # return unless (value_card = Card.search(wql).first)
      # value_card
      if input_card.type_id == YearlyVariableID
        Card.fetch input_card, year
      else
        Card.fetch input_card, company, year
      end
    end

    def raw_value value_card
      nest value_card, view: :raw_value
      raw_value =
        if value_card.metric_type == :score
          base_metric_value(value_card).value
        else
          value_card.value
        end
      wrap_with(:span, raw_value, class: "metric-value")
    end

    def score_value value_card
      return "" unless value_card.metric_type == :score
      value_card.value
    end

    def metric_thumbnail input_card
      @format.nest input_card, view: :thumbnail
    end


  end
end
