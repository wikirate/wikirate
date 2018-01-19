class Card
  class MissingAnswerQuery < AllAnswerQuery
    def run
      subjects_without_answers.map do |subject_name|
        fetch_missing_answer subject_name
      end
    end

    private

    # @return [Array<String]
    def subjects_without_answers
      Card.search(search_wql.merge(return: :name, sort: :name))
    end

    def search_wql
      wql = subject_wql
      not_ids = subject_ids_of_existing_answers
      wql[:not] = { id: not_ids.unshift("in") } if not_ids.present?
      wql.merge subject_filter_wql
    end

    def subject_ids_of_existing_answers
      Answer.where(existing_where_args).pluck(subject_key)
    end
  end
end
