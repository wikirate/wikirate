IMPORT_FIELDS = [:metric, :file_company, :year, :value, :source].freeze

attachment :metric_value_import_file, uploader: FileUploader

include_set Type::File
include_set Abstract::Import

# @return [Hash] args to create metric value card
def process_metric_value_data metric_value_data
  mv_hash = JSON.parse(metric_value_data).symbolize_keys
  mv_hash[:company] = get_corrected_company_name mv_hash
  mv_hash
end

format :html do
  def default_new_args args
    args[:hidden] = {
      success: { id: '_self', soft_redirect: false, view: :import }
    }
    super args
  end

  def default_import_table_args args
    args[:table_header] = ['Select', '#', 'Metric', 'Year', 'Value', 'Source',
                           'Company in File', 'Company in Wikirate', 'Match',
                           'Correction']
    args[:table_fields] = [:checkbox, :row, :metric, :file_company,
      :wikirate_company, :status, :correction, :year, :value, :source]
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

  view :import do |args|
    frame_and_form :update, args, class: 'nodblclick',
                   'notify-success' => 'import successful' do
      [
        _optional_render(:metric_import_flag, args),
        _optional_render(:selection_checkbox, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  def contruct_header checkbox, headers
    headers.inject(checkbox) do |row, itm|
      row.concat content_tag(:td, itm)
    end
  end
end
