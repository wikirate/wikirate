class Card
  class WikiratingAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Metric", "Raw Value", "Score", "Weight", "Points"]

    def table_rows
      @format.card.metric_card.formula_card.translation_table.map do |card_name, weight|
        card = Card.fetch(card_name)
        metric_row(card, weight)
      end
    end

    def metric_row input_card, weight
      score = score_value input_card
      points = (score.to_f * (weight.to_f / 100)).round(1)
      super(input_card).push score, "x #{weight}%", "= #{points}"
    end

    def score_value input_card
      v_card = value_card input_card
      return "" unless v_card.metric_type == :score
      v_card.value
    end
  end
end
