class Card
  class MissingAnswerQuery
    def initialize filter, paging
      @filter = filter.clone
      @paging = paging
      @filter.delete :metric_value # if we are here this is "none"
      @base_card = Card[@filter.delete(base_key)]
      @year = @filter.delete :year
    end

    def run
      all_missing
    end

    def count
      Card.search(missing_wql.merge(return: :count))
    end

    private

    # @return [Array<String]
    def subjects_without_answers
      Card.search(missing_wql.merge(return: :name, sort: :name))
    end

    def all_missing
      subjects_without_answers.map do |subject_name|
        Card.new name: new_name(subject_name), type_id: MetricValueID
      end
    end

    def missing_wql
      wql = @paging.merge type_id: subject_type_id
      not_ids = subject_ids_of_existing_answers
      wql[:not] = { id: not_ids.unshift("in") } if not_ids.present?
      return wql unless @filter
      wql.merge additional_filter_wql
    end

    def new_name company
      "#{@metric_card.name}+#{company}+#{year}"
    end

    def subject_ids_of_existing_answers
      where_args = { base_key => @base_card.id }
      if !@year || @year.to_sym == :latest
        where_args[:latest] = true
      else
        where_args[:year] = @year
      end
      Answer.where(where_args).pluck(subject_key)
    end

    def year
      @year || Time.now.year
    end
  end
end
