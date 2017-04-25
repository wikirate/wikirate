# -*- encoding : utf-8 -*-

class GeneratePdfsForLinkSources < Card::Migration
  disable_ddl_transaction!

  def up
    Card.search(type_id: Card::SourceID,
                right_plus: [Card::SourceTypeID, refer_to: "Link"],
                not: { right_plus: [Card::FileID, {}] }).each do |card|
      card.generate_pdf
    end
  end
end
