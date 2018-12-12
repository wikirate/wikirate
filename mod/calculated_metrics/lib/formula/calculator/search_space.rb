module Formula
  class Calculator
    # Keeps track of companies and years that have values for input metrics which means
    # it's possible to calculate answers for them.
    class SearchSpace
      attr_reader :mandatory_processed

      def initialize company_id=nil, year=nil
        @company_ids = company_id ? ::Set.new([company_id]) : nil
        @years = year ? ::Set.new([year]) : nil

        @mandatory_processed = false
      end

      def company_ids
        @company_ids.to_a
      end

      def fresh?
        @company_ids.nil? || @year.nil?
      end

      def present?
        !fresh? && (years? || company_ids?)
      end

      def years
        @years ? @years.to_a : []
      end

      def years?
        @years.present?
      end

      def company_ids?
        @company_ids.present?
      end

      def reset
        @company_ids = nil
        @years = nil
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
        intersect_companies company_ids
        intersect_years years
      end

      def join company_ids, years
        @fresh = false
        join_companies company_ids
        join_years years
      end

      def intersect_companies c_ids
        return unless c_ids
        @company_ids =
          @company_ids.nil? ? ::Set.new(c_ids) : @company_ids & c_ids
      end

      def intersect_years years
        return unless years
        @years = @years.nil? ? ::Set.new(years) : (@years & years.to_set)
      end

      def join_companies c_ids
        return unless c_ids
        @company_ids = @company_ids.nil? ? ::Set.new(c_ids) : (@company_ids)
      end

      def join_years years
        return unless years
        @years= @years.nil? ? ::Set.new(years) : (@years)
      end

      def merge! search_space
        if search_space.mandatory_processed
          intersect search_space.company_ids, search_space.years
        end
      end

      def applicable_companies new_ids
        new_ids = new_ids.to_set
        return new_ids if @company_ids.nil?
        if @mandatory_processed
          new_ids & @company_ids
        else
          new_ids | @company_ids
        end
      end

      def applicable_year? year
        @years.nil? || !@mandatory_processed || @years&.include?(year)
      end

      def run_out_of_options?
        return false if fresh? || !@mandatory_processed
        @company_ids.empty? || @years.empty?
      end
    end
  end
end
