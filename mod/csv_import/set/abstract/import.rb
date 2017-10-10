card_accessor :import_status
card_accessor :imported_rows

delegate :mark_as_imported, :already_imported?, to: :imported_rows_card

def csv_file
  # maybe we have to use file.read ?
  CSVFile.new file, csv_row_class, headers: :detect
end

def clean_html?
  false
end

format :html do
  def default_new_args _args
    voo.help = help_text
    voo.show! :help
  end

  def help_text
    rows = card.csv_row_class.columns.map { |s| s.to_s.humanize }
    "expected csv format: #{rows.join ' | '}"
  end

  def new_view_hidden
    hidden_tags success: { id: "_self", soft_redirect: false, view: :import }
  end

  view :core do
    output [
      download_link,
      import_link,
      last_import_status
    ]
  end

  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download "#{_render_title}"</a><br />)
    end.html_safe
  end

  def import_link
    link_to_view :import, "Import ...", rel: "nofollow", remote: false
  end

  def last_import_status
    return unless card.import_status.present?
    link_to_card card.import_status_card, "Status of last import"
  end
end
