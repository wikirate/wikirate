module Wikirate
  module MEL
    # flag methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Flags
      def flags_created
        created { cards.where type_id: :flag.card_id }
      end

      %w[wrong_value wrong_company wrong_year other_subject].each do |flag_type|
        define_method "flags_#{flag_type}" do
          flag_types[flag_type].to_i
        end
      end

      private

      def flag_cql
        { type: :flag }
      end

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
