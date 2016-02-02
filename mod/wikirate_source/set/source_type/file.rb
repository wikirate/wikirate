card_accessor :file, type: :file

format :html do
  view :original_link do |args|
    link_to (args[:title] || 'Download'), card.file_card.file.url
  end

  def icon
    'upload'
  end

  view :metric_import_link do |_args|
    return '' unless csv?
    card_link card.file_card, text: 'Import to metric values',
                              path_opts: { view: :import }
  end

  def csv?
    (mime_type = card.file_card.file.content_type) &&
      (mime_type == 'text/csv' || mime_type == 'text/comma-separated-values')
  end
end

