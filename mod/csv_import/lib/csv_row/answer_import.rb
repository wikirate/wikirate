class CSVRow
  # To be used by CSVRow classes to handle answer imports
  module AnswerImport
    def import_answer
      build_answer_create_args
      import_card answer_create_args
    end

    def answer_name
      answer_create_args[:name]
    end

    private

    def build_answer_create_args
      @answer_create_args = construct_answer_create_args
      skip :failed if errors.any?
    end

    def answer_create_args
      @answer_create_args ||= construct_answer_create_args
    end

    def check_for_duplicates
      # TODO: handle return value of check_duplication_with_existing
      check_duplication_with_existing
    end

    def check_duplication_with_existing
      return unless (source = Card[answer_name, :source])
      bucket =
        source.item_cards[0].key == @raw[:source].key ? :identical : :duplicated
      # throw :skip_row
      success.params["#{bucket}_answer".to_sym].push [@row_index, answer_name]
    end

    def construct_answer_create_args
      create_args =
        Card[metric].create_value_args @row.merge(ok_to_exist: true)
      pick_up_card_errors Card[metric]
      create_args
    end
  end
end
