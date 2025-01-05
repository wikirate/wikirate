module Wikirate
  class MEL
    # Helper methods in support of tracking details for
    # Monitoring, Evaluation, and Learning
    module Helper
      private

      def file_card
        @file_card ||= :wikirate_mel.card.fetch :file, new: { type: :file }
      end

      def csv_content headers: false
        m = measure
        CSV.generate do |csv|
          csv << m.keys if headers
          csv << m.values
        end
      end

      def full_content
        if file_card.new?
          csv_content headers: true
        else
          file_card.file.read + csv_content
        end
      end

      def tmp_file
        f = Tempfile.new "mel.csv"
        f.write full_content
        f.close
        yield f
      ensure
        f.unlink
      end

      def cards
        Card.where trash: false
      end

      def cards_of_type codename
        cards.where type_id: codename.card_id
      end

      def created
        yield.where "created_at > #{period_ago}"
      end

      def created_team &block
        created(&block).where "creator_id in (?)", team_ids
      end

      def created_others &block
        created(&block).where.not "creator_id in (?)", team_ids
      end

      def created_stewards &block
        created(&block).where "creator_id in (?)", steward_ids
      end

      def research_groups
        cards_of_type :research_group
      end

      def period_ago
        "now() - INTERVAL #{@period}"
      end
    end
  end
end
