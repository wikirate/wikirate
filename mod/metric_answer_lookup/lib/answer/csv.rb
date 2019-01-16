class Answer
  # Methods to format answer for csv output
  module Csv
    include Card::Env::Location

    def self.included host_class
      host_class.extend ClassMethods
    end

    def csv_line
      CSV.generate_line [answer_id,
                         answer_link,
                         metric_name,
                         company_name,
                         year,
                         value,
                         source_count,
                         source_link]
    end

    def answer_link
      card_url "~#{answer_id}"
    end

    def source_count
      source_field.item_names.size
    end

    def source_link
      source_field.item_cards.first&.field(:wikirate_link)&.content
    end

    def source_field
      @source_field ||=
        Card.fetch [answer_name, :source], new: { type_id: Card::PointerID }
    end

    # class methods for {Answer}
    module ClassMethods
      def csv_title
        CSV.generate_line ["ANSWER ID", "ANSWER_LINK", "METRIC NAME",
                           "COMPANY NAME", "YEAR", "VALUE", "# SOURCES", "SOURCE LINK"]
      end
    end
  end
end
