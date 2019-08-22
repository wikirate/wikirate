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

      [metric_thumbnail(input_card), input_value(a_card)]
    end

    def company
      @format.card.company_name
    end

    def year
      @format.card.year
    end

    def answer_card input_card
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

    def input_value answer_card
      a_card = answer_card.raw_answer_card
      @format.link_to_card a_card, a_card.value_card.format.pretty_value,
                           class: "metric-value _update-details"
    end

    def base_metric_card
      @format.card.metric_card.left
    end

    def base_metric_answer
      base_metric_card.field(company).field(year)
    end

    def metric_thumbnail input_card
      @format.nest input_card, view: :thumbnail
    end
  end
end
