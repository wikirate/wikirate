module Formula
  class Calculator
    # Keeps track of companies that have values for all input metrics which means
    # it's possible to calculate answers for them.
    # It's a Set of company ids for every year
    class ResultSlice < Hash
      attr_reader :company_ids
      def initialize
        super do |h, k|
          h[k] = ::Set.new
        end
        @company_ids = ::Set.new
      end

      def years
        keys
      end

      def for_year year
        self[year].to_a
      end

      def add company_id, year
        if company_id == :all
          self[year.to_i] = :all
        else
          self[year.to_i] ||= ::Set.new
          self[year.to_i] << company_id
          @company_ids << company_id
        end
      end

      def remove company_id, year
        return unless self[year.to_i].present?

        self[year.to_i].delete company_id
        delete year.to_i if self[year.to_i].empty?
      end
    end
  end
end
