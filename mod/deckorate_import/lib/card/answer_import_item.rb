class Card
  # Specifies the structure of a import item for an answer import.
  class AnswerImportItem < ImportItem
    extend CompanyImportHelper

    @columns = { metric: { map: true, suggest: true },
                 company: { map: true, auto_add: true, suggest: true },
                 year: { map: true },
                 value: {},
                 source: { map: true, separator: "; ", auto_add: true, suggest: true },
                 unpublished: { optional: true },
                 comment: { optional: true },
                 headquarters: { optional: true } }

    CSV_KEYS = %i[answer_link metric company year value
                  source_page_url].freeze

    def import_hash
      return {} unless (metric_card = Card[metric])

      metric_card.create_answer_args translate_row_hash_to_create_answer_hash
    end

    def normalize_value val
      if val.is_a?(String) && Card[metric]&.try(:categorical?)
        # really only needed for multicategory...
        val.split(";").compact.map(&:strip)
      else
        val
      end
    end

    def normalize_unpublished val
      val.to_s.downcase.in?(%w[1 true t yes y]) ? "1" : "0"
    end

    def map_source val
      result = Card::Source.search val

      # result.first.id if result.size == 1
      #
      # FIXME: below is temporary solution to speed along FTI duplicates.
      # above is preferable once we have matching.
      result.first&.id
    end

    def translate_row_hash_to_create_answer_hash
      r = input.clone
      r[:year] = r[:year].cardname if r[:year].is_a?(Integer)
      r[:ok_to_exist] = true
      r = prep_fields r
      r
    end

    def export_csv_line status
      if status.to_sym == :success && (card = Card[cardid])
        csv_line_for_card card
      else
        CSV_KEYS.map { |field| try field }
      end
    end

    def csv_line_for_card card
      card.answer.csv_line
    end

    class << self
      def auto_add_source url
        Card::Source.find_or_add_source_card(url)&.id if Card::Source.url? url
      end

      def auto_add_company value
        Card.create! type: :company, name: value,
                     skip: :type__company__requires_field__headquarters
      end

      def export_csv_header
        ::Answer.csv_titles
      end

      def source_suggestion_filter name, _import_manager
        { wikirate_link: name }
      end
    end
  end
end
