class Card
  # Template class for rendering the details table of metric answer.
  # For every metric type there is a subclass of this class.
  class AbstractAnswerDetailsTable
    class << self
      attr_accessor :columns
    end

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
      return unless (a_card = answer_card input_card)

      [metric_thumbnail(input_card), link_to_answer(a_card)]
    end

    def card
      @card ||= @format.card
    end

    def metric_card
      card.metric_card
    end

    def company
      card.company_name
    end

    def year
      card.year
    end

    def value_card
      card.value_card
    end

    def answer_card input_card
      # cql = input_card.metric_value_query
      # cql[:left][:right] = company
      # cql[:right] = year
      # return unless (value_card = Card.search(cql).first)
      # value_card
      if input_card.type_id == Card::YearlyVariableID
        Card.fetch input_card, year
      else
        Card.fetch input_card, company, year
      end
    end

    def link_to_answer answer_card
      @format.link_to_card answer_card, answer_card.value_card.format.pretty_value,
                           class: "metric-value _update-details"
    end

    def metric_thumbnail input_card
      @format.nest input_card, view: :thumbnail
    end

    # FOLLOWING ONLY APPLY TO SCORES

    def base_metric_card
      metric_card.left
    end

    def base_metric_answer
      base_metric_card.field(company).field(year)
    end
  end
end
