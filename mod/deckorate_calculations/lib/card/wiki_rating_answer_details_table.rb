class Card
  # Renders the table with details for an answer of a WikiRating metric
  class WikiRatingAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = %w[Metric Input Score Weight Points]

    def table_rows
      metric_card.weight_hash.map do |metric_id, weight|
        metric_row(metric_id.card, weight)
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

      @format.modal_link pretty_score(score_card),
                         path: { mark: score_card }, size: :xl
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

    def link_to_answer answer
      answer = answer.scored_answer_card if answer.metric_card.score?
      super answer
    end
  end
end
