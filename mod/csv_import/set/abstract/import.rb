def csv_file
  # maybe we have to use file.read ?
  CSVFile.new file, csv_row_class
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
    rows = csv_row_class.columns.map { |s| s.humanize }
    "expected csv format: #{rows.join ' | '}"
  end

  def new_view_hidden
    hidden_tags success: { id: "_self", soft_redirect: false, view: :import }
  end

  view :core do
    output [
      success_messages,
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
