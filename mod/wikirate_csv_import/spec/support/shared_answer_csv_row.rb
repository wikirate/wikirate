shared_context "answer csv row" do
  ROW_HASH =
    {
      metric: "Jedi+disturbances in the Force",
      company: "Google Inc",
      year: "2017",
      value: "yes",
      source: "http://google.com",
      comment: ""
    }.freeze

  def answer_row args={}
    ROW_HASH.merge args
  end

  def answer_csv_file data=ROW_HASH
    io = StringIO.new data.values.join ","
    CSVFile.new io, CSVRow::Structure::AnswerCSV
  end

  def answer_card args={}
    Card[answer_name(args)]
  end

  def csv_row args={}, index=1
    CSVRow::Structure::AnswerCSV.new answer_row(args), index
  end

  ROW_HASH.keys.each do |key|
    define_method "no_#{key}" do
      answer_row key => nil
    end
  end

  def existing_answer
    answer_row company: "Death Star", year: "2000"
  end

  def not_a_metric
    answer_row metric: "A"
  end

  def not_a_year
    answer_row year: "A"
  end

  def metric_not_existent
    answer_row metric: "not a metric"
  end

  def year_not_existent
    answer_row year: "not a year"
  end

  def new_company
    answer_row company: "new company"
  end

  def invalid_value
    answer_row value: "5"
  end

  def existing_source
    answer_row source: sample_source.link_url
  end

  def answer_name args={}
    if args.is_a? Symbol
      args = send args
    else
      args.reverse_merge! answer_row
    end

    [args[:metric], args[:company], args[:year]].join "+"
  end
end
