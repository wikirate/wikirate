class Card
  class WikiratingAnswerDetailsTable < AnswerDetailsTable
    @columns = ["Metric", "Raw Value", "Score", "Weight", "Points"]

    def table_rows
      card.metric_card.formula_card.translation_table.map do |card_name, weight|
        card = Card.fetch(card_name)
        metric_row(card, weight)
      end
    end

    def metric_row input_card, weight
      points = (score_value.to_f * (weight.to_f / 100)).round(1)
      super(input_card).push "x #{weight}%", "= #{points}"
    end


  end
end
