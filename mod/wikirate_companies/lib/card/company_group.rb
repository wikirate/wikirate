class Card
  # utilities for company groups
  class CompanyGroup
    class << self
      def update_large_lists
        each_large_group_list(&:update_content_from_spec)
      end

      private

      def each_large_group_list
        Count.where(right_id: :company.card_id).where("value > 10000").each do |count|
          card = count.card
          yield card if card&.type_code == :company_group
        end
      end
    end
  end
end
