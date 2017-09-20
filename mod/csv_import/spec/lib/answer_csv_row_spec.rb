require_relative "../support/shared_csv_data"

describe AnswerCSVRow do
  include_context "csv data"

  specify "answer doesn't exist" do
    expect(Card[answer_name]).not_to be_a Card
  end

  describe "import directly" do
    example "creates answer card with valid data", as_bot: true do
      row = described_class.new answer_data, 1
      row.execute_import
      expect(Card[answer_name]).to be_a Card
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
      in_stage :validate, on: :update,
               trigger: -> { update "A", content: "import!" } do
        row = described_class.new answer_data, 1
        row.execute_import as_subcard_of: self
        expect(Card[answer_name]).not_to be_a Card
      end

      expect(Card[answer_name]).to be_a Card
      expect(Card["A"]).to have_acted_on answer_name
    end


    example "existing answer" do
      import existing_answer do |run_import|
        run_import.call
        expect(Card[answer_name]).to be_a Card
      end
    end

    example "existing source" do
      import existing_source do |run_import|
        run_import.call
        expect(Card[answer_name]).to be_a Card
      end
    end

    example "existing metric" do
      import existing_source do |run_import|
        expect { run_import.call }
          .to raise_invalid_data "Google Inc is not a metric"
      end
    end

    example "new company" do
      import existing_source do |run_import|
        expect { run_import.call }
          .to raise_invalid_data "Google Inc is not a metric"
      end
    end

    example "invalid metric", as_bot: true do
      import not_a_metric do |run_import|
        expect { run_import.call }
          .to raise_invalid_data "Google Inc is not a metric"
      end
    end

    example "invalid year", as_bot: true do
      import not_a_year do |run_import|
        expect { run_import.call }
          .to raise_invalid_data "Google Inc is not a year"
      end
    end

    example "invalid value", as_bot: true do
      import invalid_value do |run_import|
        expect { run_import.call }
          .to raise_error
      end
    end

    it "aggregates errors" do
      import answer_data year: "Google Inc", metric: "2007", company: nil do |run_import|
        expect { run_import.call }
          .to raise_invalid_data "value for company missing",
                                 "2007 is not a metric",
                                 "Google Inc is not a year"
      end
    end

    def raise_invalid_data *msg
      raise_error InvalidData, msg.to_s
    end

    def import data, row_index=1
      with_test_events do
        test_event :validate, on: :update, for: "A"  do
          row = described_class.new data, row_index
          row.execute_import as_subcard_of: self
        end
        yield -> { update "A", content: "import!" }
      end
    end
  end
end
