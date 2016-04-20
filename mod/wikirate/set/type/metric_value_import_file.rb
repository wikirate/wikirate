include_set Type::File
include_set Abstract::Import

attachment :metric_value_import_file, uploader: FileUploader

format :html do
  def default_import_table_args args
    args[:table_header] = ['Select', '#', 'Metric',
                           'Company in File', 'Company in Wikirate', 'Match',
                           'Correction',
                           'Year', 'Value', 'Source']
    args[:table_fields] = [:checkbox, :row, :metric, :file_company,
                           :wikirate_company, :status, :correction,
                           :year, :value, :source]
  end

  def default_import_args args
    super args
    args.merge! optional_metric_select: :hide,
                optional_year_select: :hide
  end

  view :import_success do |args|
    structure = 'source item preview'
    redirect_content = _render_content args.merge(structure: structure)
    content_tag(:div, content_tag(:div, redirect_content,
                                  { class: 'redirect-notice' }, false),
                { id: 'source-preview-iframe',
                  class: 'webpage-preview non-previewable' },
                false)
  end

  view :core do |args|
    content = args[:success_msg] ? args[:success_msg] : ''
    content += handle_source args do |source|
      "<a href=\"#{source}\">Download #{showname args[:title]}</a><br />"
    end
    content + <<-HTML
      <a href=\"/#{card.cardname.url_key}?view=import\">Import ...</a>
    HTML
  end

  def import_fields
    [:metric, :file_company, :year, :value, :source]
  end
end
