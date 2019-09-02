class Card
  # Renders the table with details for an answer of a WikiRating metric
  class WikiRatingAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = %w[Metric Input Score Weight Points]

    def table_rows
      @format.card.metric_card.formula_card.translation_table.map do |card_name, weight|
        metric_row(Card.fetch(card_name), weight.to_f)
      end
    end

    def metric_row input_card, weight
      score_card = answer_card input_card
      super(input_card).push score_cell(score_card),
                             weight_cell(weight),
                             points_cell(score_card, weight)
    end

    def score_cell score_card
      return "" unless score_card.present?

      @format.link_to_card score_card, pretty_score(score_card), class: "_update-details"
    end

    def weight_cell weight
      "x #{format '%.2g', weight}%"
    end

    def points_cell score_card, weight
      "= #{(score_card.value.to_f * (weight / 100)).round(1)}"
    end

    def pretty_score score_card
      score_card.value_card.format.render_ten_scale
    end
  end
end
