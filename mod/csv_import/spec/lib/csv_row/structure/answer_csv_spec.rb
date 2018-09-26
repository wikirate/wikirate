require_relative "../../../support/shared_answer_csv_row"

RSpec.describe CSVRow::Structure::AnswerCSV do
  include_context "answer csv row"

  specify "answer doesn't exist" do
    expect(Card[answer_name]).not_to be_a Card
  end

  describe "import directly" do
    example "creates answer card with valid data", as_bot: true do
      row = described_class.new answer_row, 1
      row.execute_import
      expect_card(answer_name).to exist
    end
  end

  describe "import as subcard" do
    RSpec::Matchers.define :have_acted_on do |name|
      match do |card|
        action = card.acts.last.action_on Card.fetch_id(name)
        action.is_a? Card::Action
      end
    end

    example "creates answer card with valid data", as_bot: true do
      with_delayed_jobs do
        in_stage :validate, on: :update,
                            trigger: -> { update "A", content: "import!" } do
          im = ActImportManager.new self, nil
          allow(im).to receive(:log_status).and_return(true)
          allow(im).to receive(:row_finished).and_return(true)
          row = described_class.new answer_row, 1, im
          row.execute_import
        end
      end
      expect(Card[answer_name]).to be_a Card
      expect(Card["A"]).to have_acted_on answer_name
    end

    example "existing answer" do
      import existing_answer do
        expect(Card[answer_name(existing_answer)]).to be_real
      end
    end

    example "existing source" do
      import existing_source do
        expect(Card[answer_name(existing_source)]).to be_real
      end
    end

    example "not a metric" do
      import metric_not_existent do |errors|
        expect(errors).to contain_exactly '"not a metric" doesn\'t exist'
      end
    end

    example "new company" do
      import new_company do
        expect_card(answer_name(new_company)).to exist
      end
    end

    example "invalid metric", as_bot: true do
      import not_a_metric do |errors|
        expect(errors).to contain_exactly '"A" is not a metric'
      end
    end

    example "invalid year", as_bot: true do
      import not_a_year do |errors|
        expect(errors).to contain_exactly '"A" is not a year'
      end
    end

    example "invalid value", as_bot: true do
      import invalid_value do |errors|
        expect(errors).to contain_exactly /invalid option\(s\): 5/
      end
    end

    it "aggregates errors" do
      import answer_row year: "Google Inc", metric: "2007" do |errors|
        expect(errors)
          .to contain_exactly '"2007" is not a metric',
                              '"Google Inc" is not a year'
      end
    end

    def aim
      @aim ||= ActImportManager.new nil, nil
    end

    def import data, row_index=1
      with_test_events do
        test_event :validate, on: :update, for: "A" do
          row = described_class.new data, row_index, aim
          row.execute_import
        end
        update "A", content: "import!"
        yield aim.errors[row_index]
      end
    end
  end
end
