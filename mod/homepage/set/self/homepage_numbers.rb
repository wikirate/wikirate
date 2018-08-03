include_set Abstract::HamlFile

format :html do

  def haml_locals
    { categories: [:company, :metric_questions, :metric_answers, :source],
      colors: [:company, :metric, :metric, :source],
      icons: [icon_map(:wikirate_company), :help, :check, icon_map(:source) ],
      counts: [company_count, metric_answer_count, company_count, source_count],
      examples: ["CDP+Performance_Score+Cielo+2014"]
     }
  end

  def metric_question_count
    "45"
    # numbers(:metric)
  end

  def metric_answer_count
    "28,776"
    # numbers(:metric_answer)
  end

  def company_count
    "34"
    # numbers(:wikirate_company)
  end

  def source_count
    "31234"
    # numbers(:source)
  end

  def numbers card_type
    number = nest(Card.fetch(card_type), view: :count)
    number_with_delimiter(number, delimiter: ",")
  end

end
