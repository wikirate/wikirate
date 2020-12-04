class Card
  class VegaChart
    # Metric/Company Grid of answer values
    class Grid < VegaChart
      def initialize format, opts
        @invert = opts[:invert]
        super
      end

      def hash
        with_values(company_list: 0, metric_list: 1, answer_list: 4) do
          super.tap do |h|
            h[:scales] << builtin(:ten_scale_color)
            invert h
          end
        end
      end

      def layout
        super.merge builtin(:grid)
      end

      private

      # switch x and y axes
      def invert hash
        return unless @invert
        hash[:signals].first[:value] = "companies"
        map_data hash, 2, :companies
        map_data hash, 3, :metrics
        hash
      end

      def map_data hash, index, set
        hash[:data][index][:source] = set
      end
    end
  end
end
