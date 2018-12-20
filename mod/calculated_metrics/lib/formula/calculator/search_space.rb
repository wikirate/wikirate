module Formula
  class Calculator
    # Keeps track of companies and years that have values for input metrics which means
    # it's possible to calculate answers for them.
    class SearchSpace
      include AllSearchSpace

      def initialize company_id=nil, year=nil
        @company_ids = company_id ? ::Set.new([company_id]) : nil
        @years = year ? ::Set.new([year]) : nil
      end

      def point?
        year_cnt.one? && company_cnt.one?
      end

      def no_year_restriction?
        @years.nil?
      end

      def no_company_restriction?
        @company_ids.nil?
      end

      def unrestricted?
        no_year_restriction? && no_company_restriction?
      end

      def with_full_year_space
        years_backup = @years
        @years = nil
        yield
      ensure
        @years = years_backup
      end

      def company_cnt
        @company_ids.size
      end

      def year_cnt
        @years.size
      end

      def company_ids
        @company_ids.to_a
      end

      def fresh?
        @company_ids.nil? || @years.nil?
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

      def merge! search_space
        return unless search_space.mandatory_processed

        intersect search_space.company_ids, search_space.years
      end
    end
  end
end
