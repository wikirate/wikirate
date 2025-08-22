format :html do
  view :input, cache: :never do
    haml :input, file_editor: super()
  end

  view :core do
    super() + render_preview
  end

  view :preview, unknown: :missing_preview, wrap: :slot do
    send "#{preview_type}_preview"
  end

  view :missing_preview, unknown: true, wrap: :slot do
    "File currently missing for this source."
  end

  def web_editor
    form.text_field :remote_file_url, class: "d0-card-content form-control",
                                      placeholder: "http://example.com",
                                      value: params[:source_url]
  end

  def preview_type
    case card.file.content_type
    when "text/plain"            then :text
    when "application/pdf"       then :pdf
    when *SPREADSHEET_MIME_TYPES then :spreadsheet
    else                              :unknown
    end
  end

  def spreadsheet_preview
    "Previews for spreadsheets and CSVs are coming soon. " +
      link_to("Download original.", href: card.file_url, target: "_blank")
  end

  def pdf_preview
    wrap_with :div, id: "pdf-preview", class: "pdf-source-preview" do
      pdfjs_iframe pdf_url: card.file_url
    end
  end

  def text_preview
    wrap_with :pre, class: "text-source-preview p-3" do
      card.file.read
    end
  end

  def unknown_preview
    type = card.file.content_type
    wrap_with :div, class: "unknown-source-preview" do
      msg = "No preview currently available"
      msg += " for #{type} sources" if type.present?
      msg + "."
    end
  end
end
