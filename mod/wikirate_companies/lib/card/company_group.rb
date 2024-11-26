class Card
  # utilities for company groups
  class CompanyGroup
    class << self
      MINIMUM_COMPANY_COUNT = 10_000

      def update_large_lists
        Auth.as_bot do
          each_large_company_group do |group|
            next unless update_group? group
            list = group.company_card
            list.update_content_from_spec
            list.save!
          end
        end
      end

      private

      def company_group_sql
        "select c.id as group_id from card_counts ct " \
          "join cards c on ct.left_id = c.id " \
          "where c.type_id = #{:company_group.card_id} " \
          "and ct.right_id = #{:company.card_id} " \
          "and value > #{MINIMUM_COMPANY_COUNT};"
      end

      def each_large_company_group
        ActiveRecord::Base.connection.execute(company_group_sql).each do |row|
          yield row.first.card
        end
      end

      def update_group? group
        m_ids = metric_ids_for_group group
        return false unless m_ids.present?

        Answer.where(metric_id: m_ids)
              .where("updated_at > now() - interval 1 day")
              .take.present?
      end

      def metric_ids_for_group group
        spec = group.specification_card
        return unless spec.implicit?
        Card.search type: :metric, referred_to_by: spec.id, return: :id
      end
    end
  end
end
