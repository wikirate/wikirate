module Wikirate
  class MEL
    # flag methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Flags
      def flags_created
        created_others { cards_of_type :flag }
      end

      def flags_closed
        cards.joins("join cards flag on flag.id = cards.left_id")
             .where(right_id: :status.card_id,
                    db_content: :closed)
             .where("flag.type_id = #{:flag.card_id}")
             .where.not("cards.updater_id in (?)", team_ids)
             .where("cards.updated_at > #{period_ago}")
      end

      %w[wrong_value wrong_company wrong_year other_subject].each do |flag_type|
        define_method "flags_#{flag_type}" do
          flag_types[flag_type].to_i
        end
      end

      private

      def flag_types
        @flag_types ||=
          flags_created.each_with_object({}) do |flag, hash|
            flag.include_set_modules
            type = flag.flag_type_card.first_name.underscore.tr " ", "_"
            hash[type] ||= 0
            hash[type] += 1
          end
      end
    end
  end
end
