module Formula
  class Calculator
    # Keeps track of companies that have values for all input metrics which means
    # it's possible to calculate answers for them.
    # It's a Set of company ids for every year
    class CompaniesWithValues < Hash
      def initialize
        super do |h, k|
          h[k] = ::Set.new
        end
      end

      def years
        keys
      end

      def for_year year
        self[year].to_a
      end

      def add company_id, year
        self[year.to_i] ||= ::Set.new
        self[year.to_i] << company_id
      end

      # if a company definitely doesn't meet input requirements,
      # remove it completely
      def clean answer_candidates
        new_content =
          to_a.each.with_object({}) do |(year, companies_by_year), h|
            next unless answer_candidates.applicable_year? year
            h[year] = answer_candidates.applicable_companies companies_by_year
          end
        replace new_content
      end
    end
  end
end
