class Card
  class YearlyVariable
    class Helper
      extend Card::Model::SaveHelper
    end

    class << self
      def create args
        Card.create! attributes_hash(args)
      end

      def create_or_update args
        Helper.create_or_update attributes_hash(args)
      end

      def attributes_hash args
        {
          name: args[:name],
          type_id: Card::YearlyVariableID,
          subcards: subcards(args[:values])
        }
      end

      def subcards values
        return {} unless values

        subcards = {}
        case values
        when Array
          start = args[:first_year]
          start.upto(start + values.size).with_index do |year, i|
            subcards.merge! value_subcard(year, values[i])
          end
        when Hash
          values.each do |year, content|
            subcards.merge! value_subcard year, content
          end
        end
        subcards
      end

      def value_subcard year, value
        {
          "+#{year}" => {
            type_id: Card::YearlyAnswerID,
            "+value" => {
              type_id: Card::YearlyValueID,
              content: value
            }
          }
        }
      end
    end
  end
end
