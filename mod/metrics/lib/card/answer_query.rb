class Card
  class AnswerQuery
    include FilterOptions
    include FieldConditions
    include AllAndMissing
    include Where

    FILTER_TRANSLATIONS = {}.freeze

    def initialize filter, sorting={}, paging={}
      @filter_args = filter.deep_symbolize_keys
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @values = []
      @restrict_to_ids = {}

      @card_conditions = []
      @card_values = []
      @card_ids = []

      translate_filter_args
      @join = prepare_join @filter_args[:status]
      process_filters
    end

    # TODO: support optionally returning answer objects

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      return [] if @empty_result
      @join ? card_run : answer_run
    end

    def answer_run
      sort_and_page { answer_query }.answer_cards
    end

    def answer_query
      Answer.where answer_conditions
    end

    def card_run
      card_query.map do |record|
        if record.id
          Answer.find(record.id).card
        else
          Card.new name: new_name(record.name), type_id: MetricAnswerID
        end
      end
    end

    def new_name_year
      @new_name_year ||= determine_new_name_year
    end

    def determine_new_name_year
      year = @filter_args[:year]
      year.blank? || year.to_s == "latest" ? Time.now.year : year
    end

    def card_query
      sql =
        "SELECT answers.id, #{@subject}.name " \
        "FROM cards AS #{@subject} " \
        "LEFT JOIN answers ON #{@subject}.id = #{@subject}_id AND #{answer_conditions} " \
        "WHERE #{card_conditions} "
      puts "SQL = #{sql}"
      Card.find_by_sql(sql)
    end

    def sort_and_page
      yield.sort(@sort_args).paging(@paging_args)
    end

    def prepare_join status
      return false unless status.in? %i[all none]

      @subject = subject
      raise "must have #subject_codename for status: all or none" unless @subject

      @card_conditions << " #{@subject}.type_id = ? "
      @card_values << subject_type_id

      not_researched if status == :none
      true
    end

    def not_researched
      @card_conditions << " answers.id is null "
    end

    def process_filters
      @filter_args.each { |k, v| process_filter_option k, v if v.present? }
      @restrict_to_ids.each { |k, v| filter k, v }
    end

    def count
      return missing_answer_query.count if find_missing?(additional_filter)
      where(additional_filter).count
    end

    def value_count additional_filter={}
      where(additional_filter).select(:value).uniq.count
    end

    def limit
      @paging_args[:limit]
    end

    private

    def translate_filter_args
      self.class::FILTER_TRANSLATIONS.each do |key, standard_key|
        next unless (value = @filter_args.delete(key))

        @filter_args[standard_key] = value
      end
    end
  end
end
