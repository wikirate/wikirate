class Card
  class MissingAnswerQuery
    def initialize filter
      @filter = filter.clone
      @filter.delete :metric_value # if we are here this is "none"
      @base_card = Card[@filter.delete(base_key)]
      @year = @filter.delete :year
    end

    def run
      all_missing
    end

    private

    # @return [Array<String]
    def subjects_without_answers
      Card.search(missing_wql.merge(return: :name))
    end

    def all_missing
      subjects_without_answers.map do |subject_name|
        Card.new name: new_name(subject_name), type_id: MetricValueID
      end
    end

    def missing_wql
      wql = {
        type_id: subject_type_id,
        not: { id: ["in", *subject_ids_of_existing_answers] }
      }
      return wql unless @filter
      wql.merge additional_filter_wql
    end

    def new_name company
      "#{@metric_card.name}+#{company}+#{year}"
    end

    def subject_ids_of_existing_answers
      where_args = { base_key => @base_card.id }
      if @year
        where_args[:year] = @year
      else
        where_args[:latest] = true
      end
      Answer.where(where_args).pluck(subject_key)
    end

    def year
      @year || Time.now.year
    end
  end
end
