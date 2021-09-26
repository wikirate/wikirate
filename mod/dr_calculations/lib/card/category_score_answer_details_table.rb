class Card
  # Renders the table with details for an answer of a score metric
  class CategoryScoreAnswerDetailsTable < AbstractAnswerDetailsTable
    @columns = ["Scored Option", "Value"]

    ICON_MAP = { true => "check-circle", false => "circle" }.freeze

    def table_rows
      translation_hash.map do |option, value|
        Option.new(self, option, value).table_row_hash
      end
    end

    def translation_hash
      @translation_hash ||= metric_card.formula_card.translation_hash
    end

    def icon_tag checked
      @icon_tags ||= {}
      @icon_tags[checked] ||= @format.fa_icon ICON_MAP[checked]
    end

    def checked_options
      @checked_options ||= base_metric_answer.value_card.raw_value
    end

    def link_to_answer option
      @format.link_to_card base_metric_answer, option,
                           class: "metric-value _update-details"
    end

    def score_links
      checked_options.map { |o| link_to_answer translation_hash[o] }
    end

    # category scores have a row for each of the metric's value options.
    # Option objects help track their state.
    class Option
      attr_reader :table_builder

      def initialize table_builder, option, value
        @table_builder = table_builder
        @option = option
        @value = value
      end

      delegate :checked_options, :link_to_answer, :icon_tag, to: :table_builder

      def table_row_hash
        { content: table_row_content, class: table_row_class }
      end

      def table_row_content
        ["#{icon_tag checked?} #{option_content}", @value]
      end

      def option_content
        checked? ? link_to_answer(@option) : @option
      end

      def checked?
        checked_options.include? @option
      end

      def table_row_class
        "score-option score-option-#{checked? ? :checked : :unchecked}"
      end
    end
  end
end
