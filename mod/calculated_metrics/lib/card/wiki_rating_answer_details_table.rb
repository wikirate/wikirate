class Card
  # Renders the table with details for an answer of a WikiRating metric
  class WikiRatingAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Metric", "Input", "Score", "Weight", "Points"]

    def table_rows
      @format.card.metric_card.formula_card.translation_table.map do |card_name, weight|
        metric_row(Card.fetch(card_name), weight)
      end
    end

    def metric_row input_card, weight
      score_card = answer_card input_card
      score = score_card.value
      super(input_card).push score_cell(score_card, score),
                             weight_cell(weight),
                             points_cell(score, weight)
    end

    def score_cell score_card, score
      return "" unless score_card.present?
      @format.link_to_card score_card, @format.colorify(score), class: "_update-details"
    end

    def weight_cell weight
      "x #{weight}%"
    end

    def points_cell score, weight
      points = (score.to_f * (weight.to_f / 100)).round(1)
      "= #{points}"
    end
  end
end
