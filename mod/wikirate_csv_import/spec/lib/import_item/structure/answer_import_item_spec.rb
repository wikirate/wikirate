RSpec.describe AnswerImportItem do
  specify "answer doesn't exist" do
    expect(Card[answer_name]).not_to be_a Card
  end

  def import row_hash
    row = described_class.new row_hash
    row.execute_import
    row
  end

  describe "#execute_import" do
    example "creates answer card with valid data", as_bot: true do
      import answer_row
      expect_card(answer_name).to exist
    end

    example "updates answer with" do
      import existing_answer
      expect(Card[answer_name(existing_answer)]).to be_real
    end

    # example "existing source" do
    #   import existing_source do
    #     expect(Card[answer_name].source_card.first]).to be_real
    #   end
    # end

    example "not a metric" do
      expect(import(metric_not_existent).errors)
        .to contain_exactly("invalid metric: Never Met Rick")
    end

    example "invalid metric", as_bot: true do
      expect(import(not_a_metric).errors)
        .to contain_exactly("invalid metric: A")
    end

    example "invalid year", as_bot: true do
      expect(import(not_a_year).errors)
        .to contain_exactly("invalid year: A")
    end

    # NOTE: this is not caught by import validation but by card validation
    example "invalid value", as_bot: true do
      expect(import(invalid_value).errors).to contain_exactly(/invalid option\(s\): 5/)
    end

    it "aggregates errors" do
      expect(import(answer_row(year: "Google Inc", metric: "2007")).errors)
        .to contain_exactly "invalid metric: 2007", "invalid year: Google Inc"
    end
  end

  ROW_HASH =
    {
      metric: "Jedi+disturbances in the Force",
      wikirate_company: "Google Inc",
      year: "2017",
      value: "yes",
      source: :opera_source.cardname,
      comment: ""
    }.freeze

  def answer_row args={}
    ROW_HASH.merge args
  end

  def answer_card args={}
    Card[answer_name(args)]
  end

  def import_item args={}, index=1
    AnswerImportItem.new answer_row(args), index
  end

  ROW_HASH.each_key do |key|
    define_method "no_#{key}" do
      answer_row key => nil
    end
  end

  def existing_answer
    answer_row wikirate_company: "Death Star", year: "2000"
  end

  def not_a_metric
    answer_row metric: "A"
  end

  def not_a_year
    answer_row year: "A"
  end

  def metric_not_existent
    answer_row metric: "Never Met Rick"
  end

  def year_not_existent
    answer_row year: "not a year"
  end

  def new_company
    answer_row wikirate_company: "new company"
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

    [args[:metric], args[:wikirate_company], args[:year]].join "+"
  end
end
