class Card
  class YearlyVariable
    class Helper
      extend Card::ActiveRecordHelper
    end
    class << self
      def create args
        Card.create! attributes_hash(args)
      end

      def create_or_update args
        Helper.create_or_update attributes_hash(args)
      end

      def attributes_hash args
        subcards = {}

        if (values = args[:values])
          if values.is_a? Array
            start = args[:first_year]
            start.upto(start + values.size).with_index do |year, i|
              subcards.merge! value_subcard(year, values[i])
            end
          else
            values.each do |year, value|
              subcards.merge! value_subcard(year, value)
            end
          end
        end
        {
          name: args[:name],
          type_id: Card::YearlyVariableID,
          subcards: subcards
        }
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
