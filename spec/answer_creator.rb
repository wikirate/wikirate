module Deckorate
  # test-only API for creating answer
  class AnswerCreator
    def initialize metric=nil, test_source=false, &answer_block
      @metric = metric
      @metric = Card[metric] unless metric.is_a? Card
      @test_source = test_source
      define_singleton_method(:add_answers, answer_block)
    end

    def create_answer company, year, value
      variant = @metric.relation? ? :relationship : :standard
      send "create_#{variant}_answer", value, create_answer_args(company, year)
    end

    def add_answer_to metric
      @metric = metric
      add_answers
    end

    private

    def create_relationship_answer value, args
      value.each do |company, relationship_value|
        @metric.create_answer args.merge(related_company: company,
                                         value: relationship_value)
      end
    end

    def create_standard_answer value, args
      if value.is_a? Hash
        args.merge! value
      else
        args[:value] = value.to_s
      end
      @metric.create_answer args
    end

    def create_answer_args company, year
      args = { company: company.to_s, year: year }
      prep_source args
      args
    end

    def prep_source args
      return unless @metric.researchable? && @test_source
      args[:source] ||= test_source_card
    end

    def test_source_card
      test_source_mark = @test_source == true ? :opera_source : @test_source
      Card[test_source_mark]
    end

    # method_name is a company
    def method_missing method_name, *args
      return super unless respond_to_missing? method_name

      args.first.each_pair do |year, value|
        create_answer method_name, year, value
      end
    end

    def respond_to_missing? method_name
      method_name.to_s.card&.type_id == Card::CompanyID
    end
  end
end
