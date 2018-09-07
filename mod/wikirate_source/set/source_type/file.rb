card_accessor :file, type: :file

format :html do
  view :original_link do
    link_to (voo.title || "Download"), path: card.file_card.file.url
  end

  def icon
    "upload"
  end
end
