card_accessor :import_status

def csv_file
  # maybe we have to use file.read ?
  CSVFile.new file, csv_row_class
end

def clean_html?
  false
end

def already_imported? row_index
  imported_rows.include? row_index
end

def imported_rows
  @imported_rows ||= ::Set.new fetch_imported_indices
end

def fetch_imported_indices
  return [] unless (ir = fetch(trait: :imported_rows)) || ir.content.blank?
  JSON.parse ir.content
rescue JSON::ParserError => e
  []
end

def mark_as_imported row_index
  imported_rows << row_index
  fetch(trait: :imported_rows, new: {}).update_attributes content: imported_rows.to_json
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
      import_link.html_safe
    ]
  end

  def download_link
    handle_source do |source|
      %(<a href="#{source}" rel="nofollow">Download #{showname voo.title}</a><br />)
    end.html_safe
  end

  def import_link
    link_to_view :import, "Import ...", rel: "nofollow", remote: false
  end
end
