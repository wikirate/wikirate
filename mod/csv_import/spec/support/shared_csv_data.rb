shared_context "csv data" do
  ANSWER_DATA = {
        metric: "Jedi+disturbances in the Force",
        company: "Google Inc",
        year: "2017",
        value: "yes",
        source: "http://google.com",
        comment: ""
      }

  def answer_data args={}
    ANSWER_DATA.merge args
  end

  def answer_csv_file data=ANSWER_DATA
    io = StringIO.new data.values.join ","
    CSVFile.new io, CSVRow::Structure::AnswerCSV
  end

  def answer_card args={}
    Card[answer_name(args)]
  end

  def csv_row args={}, index=1
    CSVRow::Structure::AnswerCSV.new answer_data(args), index
  end

  ANSWER_DATA.keys.each do |key|
    define_method "no_#{key}" do
      answer_data key => nil
    end
  end

  def existing_answer
    answer_data company: "Death Star", year: "2000"
  end

  def not_a_metric
    answer_data metric: "Google Inc"
  end

  def not_a_year
    answer_data year: "Google Inc"
  end

  def new_company
    answer_data company: "new company"
  end

  def invalid_value
    answer_data value: "5"
  end

  def existing_source
    answer_data source: sample_source.url
  end

  def answer_name args={}
    args.reverse_merge! answer_data
    [args[:metric], args[:company], args[:year]].join "+"
  end
end
