module Formula
  class Calculator
    # Keeps track of companies that have values for all input metrics which means
    # it's possible to calculate answers for them.
    # It's a Set of company ids.
    class CompanyList < Set
      def initialize requirement, company_id
        @requirement = requirement

        if company_id
          super([company_id])
        else
          @fresh = true
          super()
        end
      end

      def reset
        @fresh = true
      end

      def update company_ids
        updated_set =
          if @fresh
            # first input item: add all company ids
            @fresh = false
            company_ids.to_set
          else
            # remove all companies that don't have values for all input items
            applicable_companies company_ids
          end
        replace updated_set
      end

      def all_input_required?
        @requirement == :all
      end

      def applicable_companies new_ids=nil
        new_ids = new_ids.to_set
        return new_ids if @fresh
        if all_input_required?
          self & new_ids
        else
          self | new_ids
        end
      end

      def run_out_of_options?
        return false if @fresh or !all_input_required?
        empty?
      end
    end
  end
end
