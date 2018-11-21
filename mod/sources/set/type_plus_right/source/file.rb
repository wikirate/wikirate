include_set Abstract::Pdfjs
include_set Abstract::Tabs

EXCEL_MIME_TYPES = %w[
  application/vnd.ms-excel
  application/msexcel
  application/x-msexcel
  application/x-ms-excel
  application/x-excel
  application/x-dos_ms_excel
  application/xls
  application/x-xls
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
].freeze

CSV_MIME_TYPES = %w[
  text/csv
  application/csv
].freeze

ACCEPTED_MIME_TYPES = (%w[
  text/plain
  text/html
  application/pdf
] + EXCEL_MIME_TYPES + CSV_MIME_TYPES).freeze

CONVERT_FOR_PREVIEW = (EXCEL_MIME_TYPES + CSV_MIME_TYPES).freeze

def file_changed?
  !db_content_before_act.empty?
end

def preview_card?
  file.content_type.in? CONVERT_FOR_PREVIEW
end

format :html do
  view :editor do
    haml :editor, file_editor: super()
  end

  view :preview do
    send "#{preview_type}_preview"
  end

  def web_editor
    form.text_field :remote_file_url, class: "d0-card-content form-control",
                                      placeholder: "http://example.com",
                                      value: params[:source_url]
  end

  def preview_type
    case card.file.content_type
    when "text/plain"      then :text
    when "application/pdf" then :pdf
    else                        :unknown
    end
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
    wrap_with :div, class: "unknown-source-preview" do
      "No preview currently available for #{card.file.content_type} sources"
    end
  end
end
