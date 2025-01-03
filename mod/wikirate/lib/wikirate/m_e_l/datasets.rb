module Wikirate
  class MEL
    # dataset methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Datasets
      COMPLETION_CATEGORY = {
        complete: 100,
        almost: 90,
        majority: 50,
        incomplete: 0
      }.freeze

      def datasets_created
        created { datasets }
      end

      def datasets_created_stewards
        created_stewards { datasets }
      end

      COMPLETION_CATEGORY.each_key do |category|
        define_method "datasets_category_#{category}" do
          dataset_completion[category].to_i
        end
      end

      private

      def datasets
        cards_of_type :dataset
      end

      def dataset_completion
        @dataset_completion ||=
          datasets.each_with_object({}) do |dataset, hash|
            dataset.include_set_modules
            category = dataset_category dataset.percent_researched
            hash[category] ||= 0
            hash[category] += 1
          end
      end

      def dataset_category completion
        COMPLETION_CATEGORY.each do |cat, floor|
          return cat if completion >= floor
        end
        :error
      end
    end
  end
end
