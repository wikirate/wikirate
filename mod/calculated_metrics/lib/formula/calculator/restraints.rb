module Formula
  class Calculator
    # limit calculation to applicable years / companies
    module Restraints
      private

      def with_restraints companies, years
        c = restraint @applicable_companies, companies
        y = restraint @applicable_years, years

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
        intersection = integers(applicable) & integers(local)
        intersection.blank? ? false : intersection
      end

      def integers restraint
        Array.wrap(restraint).map(&:to_i)
      end
    end
  end
end
