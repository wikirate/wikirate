attachment :metric_value_import_file, uploader: FileUploader

include_set Type::File
include_set Abstract::Import

def valid_import_data? data
  data.is_a? Array
end

# @return [Hash] args to create metric value card
def process_metric_value_data metric_value_data
  mv_hash = JSON.parse(metric_value_data)
  company = mv_hash[:company]
  correction_key = [mv_hash[:metric], company, mv_hash[:year]].join '+'
  corrected_company = correct_company_name company, correction_key
  if company != corrected_company
    Card[corrected_company].add_alias company
  end
  mv_hash[:company] = corrected_company
  mv_hash
end

format :html do
  def default_new_args args
    args[:hidden] = {
      success: { id: '_self', soft_redirect: false, view: :import_table }
    }
    super args
  end

  def default_import_table_args args
    args[:table_header] = ['Select', 'Metric', 'Year', 'Value', 'Source',
                           'Company in File', 'Company in Wikirate', 'Match',
                           'Correction']
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
      <a href=\"/#{card.cardname.url_key}?view=import\">Click to import</a>
    HTML
  end

  view :import do |args|
    frame_and_form :update, args, class: 'nodblclick' do
      [
        _optional_render(:metric_import_flag, args),
        _optional_render(:selection_checkbox, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  def field_to_correct_company comp_name
    input = text_field_tag("corrected_company_name[#{comp_name}]", '',
                           class: 'company_autocomplete')
    content_tag(:td, input)
  end

  def render_row hash, row
    row_hash = row_to_hash row
    file_company = row_hash[:company]
    wikirate_company, status = matched_company(hash, file_company)
    row_content = checkbox_row file_company, wikirate_company, status, row_hash
    if status != :exact
      comp_name = wikirate_company.empty? ? file_company : wikirate_company
      key_name = "#{row_hash[:metric]}+#{comp_name}+#{row_hash[:year]}"
      row_content += field_to_correct_company key_name
    end
    row_content
  end

  def row_to_hash row
    {
      metric: row[0],
      company: row[1],
      year: row[2],
      value: row[3],
      source: row[4]
    }
  end

  def metric_value_checkbox key_hash, checked
    content_tag(:td) do
      check_box_tag 'metric_values[]', key_hash.to_json, checked
    end
  end

  def contruct_header checkbox, headers
    headers.inject(checkbox) do |row, itm|
      row.concat content_tag(:td, itm)
    end
  end

  def checkbox_row file_company, wikirate_company, status, row_hash
    checked = [:partial, :exact, :alias].include? status
    company = status == :none ? file_company : wikirate_company
    key_hash = row_hash.deep_dup
    key_hash[:company] = company
    checkbox = metric_value_checkbox key_hash, checked
    fields = [
      row_hash[:metric], row_hash[:year], row_hash[:value], row_hash[:source],
      file_company, wikirate_company, status.to_s]
    fields.inject(checkbox) do |row, itm|
      row.concat content_tag(:td, itm)
    end
  end
end
