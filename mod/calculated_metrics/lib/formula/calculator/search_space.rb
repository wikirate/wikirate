module Formula
  class Calculator
    # Keeps track of companies and years that have values for input metrics which means
    # it's possible to calculate answers for them.
    class SearchSpace
      attr_reader :mandatory_processed

      def initialize company_id, year
        @company_ids = company_id ? ::Set.new([company_id]) : ::Set.new
        @years = year ? ::Set.new([year]) : ::Set.new

        @fresh = company_id.nil? && year.nil?

        @mandatory_processed = false
      end

      def company_ids
        @company_ids.to_a
      end

      def present?
        !@fresh && (years? || company_ids?)
      end

      def years
        @years.to_a
      end

      def years?
        @years.present?
      end

      def company_ids?
        @company_ids.present?
      end

      def reset
        @fresh = true
        @company_ids = ::Set.new
        @years = ::Set.new
      end

      def update company_ids, years, mandatory
        if mandatory
          @mandatory_processed = true
          intersect company_ids, years
        elsif !@mandatory_processed
          join company_ids, years
        end
        # if this input item one is not mandatory but we processed already a mandatory
        # input item then this one has no effect
      end

      def intersect company_ids, years
        if @fresh
          @fresh = false
          @company_ids = ::Set.new company_ids
          @years = ::Set.new years
        else
          @company_ids &= company_ids
          @years &= years
        end
      end

      def join company_ids, years
        @fresh = false
        @company_ids |= company_ids
        @years |= years
      end

      def merge! search_space
        if search_space.mandatory_processed
          intersect search_space.company_ids, search_space.years
        end
      end

      def applicable_companies new_ids
        new_ids = new_ids.to_set
        return new_ids if @fresh
        if @mandatory_processed
          new_ids & @company_ids
        else
          new_ids | @years
        end
      end

      def run_out_of_options?
        return false if @fresh || !@mandatory_processed
        @company_ids.empty? || @years.empty?
      end
    end
  end
end
