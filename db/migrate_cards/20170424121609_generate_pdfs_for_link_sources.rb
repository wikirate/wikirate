# -*- encoding : utf-8 -*-

class GeneratePdfsForLinkSources < Card::Migration
  disable_ddl_transaction!

  def up
    Card.search(type_id: Card::SourceID,
                right_plus: [Card::SourceTypeID, refer_to: "Link"],
                not: { right_plus: [Card::FileID, {}] }).each do |card|
      puts card.name
      if card.file_link?
        card.download_and_add_file
      else
        card.generate_pdf
      end
    end
  end
end
