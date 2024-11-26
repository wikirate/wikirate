class Calculate
  class Calculator
    class SearchLog
      def initialize
        @full_search = false
        @all_years_searched = ::Set.new
        @all_companies_searched = ::Set.new
        @answer_searched = Hash.new_nested ::Set
      end

      def searched? company_id: nil, year: nil
        @full_search || explicitly_searched?(company_id: company_id, year: year) || false
      end

      def update search_space
        return if @full_search  # no update needed

        if search_space.unrestricted?
          @full_search = true
        elsif search_space.no_year_restriction?
          @all_years_searched.merge search_space.company_ids
        elsif search_space.no_company_restriction?
          @all_companies_searched.merge search_space.years
        else
          search_space.years.each do |y|
            @answer_searched[y.to_i].merge search_space.company_ids
          end
        end
      end

      private

      def explicitly_searched? company_id: nil, year: nil
        if company_id && year
          searched_answer? company_id, year
        elsif year
          searched_year? year
        elsif company_id
          searched_company_id? company_id
        end
      end

      def searched_answer? company_id, year
        @answer_searched[year.to_i].include?(company_id)
      end

      def searched_year? year
        @all_companies_searched.include? year.to_i
      end

      def searched_company_id? company_id
        @all_years_searched.include? company_id
      end
    end
  end
end
