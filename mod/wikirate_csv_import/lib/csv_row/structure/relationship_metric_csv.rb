class CsvRow
  module Structure
    # This class provides an interface to import relationship metrics
    class RelationshipMetricCSV < CsvRow
      require_dependency "csv_row"

      @columns = [:designer, :title, :inverse, :value_type, :value_options, :unit]
      @required = [:designer, :title, :value_type, :inverse]

      def initialize row, index
        super
        @designer = @row[:designer]
        @name = "#{@designer}+#{@row[:title]}"
        normalize_value_options
      end

      def import
        ensure_designer
        create_or_update_card @name, type: Card::MetricID, subfields: subfields
      end

      private

      def subfields
        subs = { metric_type: "Relationship", inverse_title: @row[:inverse] }
        [:value_type, :value_options, :unit].each_with_object(subs) do |field, hash|
          next unless @row[field]
          hash[field] = @row[field]
        end
      end

      def ensure_designer
        ensure_card @designer, type_id: Card::ResearchGroupID
      end

      def normalize_value_options
        return unless @row[:value_options]
        @row[:value_options] =
          @row[:value_options].split("/").map(&:strip).to_pointer_content
      end
    end
  end
end
