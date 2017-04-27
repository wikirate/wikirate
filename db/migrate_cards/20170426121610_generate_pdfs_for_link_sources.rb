# -*- encoding : utf-8 -*-

class GeneratePdfsForLinkSources < Card::Migration
  disable_ddl_transaction!

  def up
    # Card.search(type_id: Card::SourceID,
    #             right_plus: [Card::SourceTypeID, refer_to: "Link"],
    #             not: { right_plus: [Card::FileID, {}] }).each do |card|
    #   if card.file_link?
    #     file_url = Addressable::URI.escape card.url
    #     ensure_card [card, :file], remote_file_url: file_url, type_id: FileID
    #     ensure_card [card, :source_type], content: "[[#{Card[:file].name}]]",
    #                                       type_id: Card::PointerID
    #   elsif card.html_link?
    #     card.generate_pdf
    #   end
    # end
  end
end
