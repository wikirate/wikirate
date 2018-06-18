class Card
  # Renders the table with details for an answer of a WikiRating metric
  class WikiRatingAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Metric", "Raw Value", "Score", "Weight", "Points"]

    def table_rows
      @format.card.metric_card.formula_card.translation_table.map do |card_name, weight|
        card = Card.fetch(card_name)
        metric_row(card, weight)
      end
    end

    def metric_row input_card, weight
      score_card, score = score_value input_card
      super(input_card).push score_cell(score_card, score),
                             "x #{weight}%",
                             "= #{row_points(score, weight)}"
    end

    def row_points score, weight
      (score.to_f * (weight.to_f / 100)).round(1)
    end

    def score_value input_card
      score_card = value_card input_card
      return [nil, ""] unless score_card.metric_type == :score
      [score_card, score_card.value]
    end

    def score_cell score_card, score
      return "" unless score_card.present?
      @format.link_to_card score_card, @format.colorify(score)
    end
  end
end
