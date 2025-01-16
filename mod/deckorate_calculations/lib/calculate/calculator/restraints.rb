class Calculate
  class Calculator
    # limit calculation to applicable years / companies
    module Restraints
      def restrain_to companies: nil, years: nil
        @requested_companies = integers companies
        @requested_years = integers years
      end

      private

      def with_restraints
        c = restraint @applicable_companies, @requested_companies
        y = restraint @applicable_years, @requested_years

        # puts "#{companies} => #{c}, #{years} = #{y}"
        return if [c, y].include? false

        yield c, y
      end

      def restraint applicable, local
        if !applicable.present?
          local
        elsif !local.present?
          applicable
        else
          restraint_intersection applicable, local
        end
      end

      def restraint_intersection applicable, local
        intersection = applicable & local
        intersection.blank? ? false : intersection
      end

      def integers restraint
        Array.wrap(restraint).compact.map(&:to_i).uniq
      end
    end
  end
end
