card_accessor :file, type: :file

format :html do
  view :original_link do
    link_to (voo.title || "Download"), path: card.file_card.file.url
  end

  def icon
    "upload"
  end

  view :metric_import_link do
    return "" unless csv?
    link_to_card card.file_card, "Import to metric values",
                 path: { view: :import }
  end

  def csv?
    card.file_card.file.content_type.in? ["text/csv", "text/comma-separated-values"]
  end
end
