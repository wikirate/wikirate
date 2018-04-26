module Formula
  class Calculator
    # Manages the two different types of input values: metrics and yearly variables
    class ValueStore
      def initialize input_list
        @values = {
          metric_value: Hash.new_nested(Hash, Hash),
          yearly_value: Hash.new_nested(Hash)
        }
        @type = input_list.each_with_object({}) do |input_item, h|
          h[input_item.card_id] =
            input_item.type == :yearly_value ? :yearly_value : :metric_value
        end
      end

      def get card_id, company, year=nil
        dig_args = [card_id, (company if @type[card_id] == :metric_value), year].compact
        values(card_id).dig(*dig_args)
      end

      def add card_id, *args
        value = args.pop
        year = args.pop
        values(card_id).dig(card_id, *args).merge!(year.to_i => value)
      end

      def values card_id
        raise "card_id not part of the input list: #{card_id}" unless @type[card_id]
        @values[@type[card_id]]
      end
    end
  end
end
