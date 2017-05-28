class Card
  class MissingAnswerQuery < AllAnswerQuery
    def run
      subjects_without_answers.map do |subject_name|
        Card.new name: new_name(subject_name), type_id: MetricValueID
      end
    end

    def count
      Card.search(search_wql.merge(return: :count))
    end

    def add_filter filter_args
      nil
    end

    private

    # @return [Array<String]
    def subjects_without_answers
      Card.search(search_wql.merge(return: :name, sort: :name))
    end

    def search_wql
      wql = @paging.merge type_id: subject_type_id
      not_ids = subject_ids_of_existing_answers
      wql[:not] = { id: not_ids.unshift("in") } if not_ids.present?
      return wql unless @filter
      wql.merge additional_filter_wql
    end

    def subject_ids_of_existing_answers
      Answer.where(existing_where_args).pluck(subject_key)
    end
  end
end
