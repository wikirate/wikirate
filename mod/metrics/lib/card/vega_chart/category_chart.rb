class Card
  class VegaChart
    # chart for categorical metrics
    # shows companies per category
    class CategoryChart < VerticalBars
      MAX_CATEGORIES = 10

      def generate_data
        display_categories.each do |category, count|
          add_label(options_hash[category] || category) if special_labels?
          add_data category, count
        end
      end

      def options_hash
        @options_hash ||= metric_card.value_options_card&.parse_content&.invert || {}
      end

      def special_labels?
        return @special_labels unless @special_labels.nil?

        @special_labels = metric_card.value_options_card&.type_id == Card::JsonID
      end

      def display_categories
        otherize_categories categories_by_count
      end

      def otherize_categories cat
        other = i = 0
        cat.each_key do |key|
          other += cat.delete(key) if i > MAX_CATEGORIES
          i += 1
        end
        cat["Other"] = other if other.positive?
        cat
      end

      def categories_by_count
        clean_categories.clone.sort_by { |_k, v| v }.reverse.to_h
      end

      def clean_categories
        handle_multi_category @filter_query.count_by_group(:value)
      end

      def handle_multi_category category_hash
        category_hash.each_with_object({}) do |(key, count), h|
          key.split(/,\s+/).each do |cat|
            h[cat] = h[cat].to_i + count
          end
        end
      end

      private

      def x_axis
        axis = super.deep_merge title: "Categories"
        axis[:scale] = "x_label" if special_labels?
        axis
      end

      def scales
        return super unless special_labels?

        super << { name: "x_label", type: "point", range: "width", domain: @labels }
      end

      # @return true if the bar given by its filter
      #   is supposed to be highlighted
      def highlight? value
        return true unless @highlight_value

        @highlight_value == value
      end
    end
  end
end
