attachment :metric_value_import_file, uploader: FileUploader

include Type::File
include Type::File::SelectedAction
include Card::Set::Abstract::Import

format do
  include Type::File::Format
end

format :file do
  include Type::File::FileFormat
end

event :validate_import, :prepare_to_validate,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
end

def parse_hash mv_hash
  [mv_hash['metric'], mv_hash['company'], mv_hash['year'],
   mv_hash['value'], mv_hash['source']]
end

event :import_csv, :prepare_to_store,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
  corrected_company_hash = clean_corrected_company_hash
  if (metric_values = Env.params[:metric_values]) && metric_values.is_a?(Array)
    metric_values.each do |metric_value|
      mv_hash = JSON.parse(metric_value)
      metric, company, year, value, source = parse_hash mv_hash
      correct_company_key = "#{metric}+#{company}"\
                            "+#{year}"
      potential_alias_name = company
      final_company_name = corrected_company_hash[correct_company_key] ||
                           company
      if final_company_name
        company = final_company_name
        unless Card.exists? final_company_name
          Card.create! name: final_company_name, type_id: WikirateCompanyID
        end
      end

      # add corrected name to alias
      if (cmp_name = corrected_company_hash[correct_company_key])
        alias_card = Card.fetch "#{cmp_name}+aliases",
                                new: { type_id: Card::PointerID }
        alias_card.insert_item! 0, potential_alias_name
      end

      metric_value_card_name = [metric, company, year].join '+'
      mv_subcards = metric_value_subcards metric, company, year, value, source
      metric_value_card =
        if (metric_value_card = Card[metric_value_card_name])
          metric_value_card.update_attributes subcards: mv_subcards
          metric_value_card
        else
          Card.create type_id: Card::MetricValueID, subcards: mv_subcards
        end
      next if metric_value_card.errors.empty?
      metric_value_card.errors.each do |key, error_value|
        errors.add key, error_value
      end
    end
    if errors.empty?
      abort success: {
        slot: {
          success_msg: 'Import Successfully <br />'
        }
      }
    else
      abort :failure
    end
  end
end

format :html do
  include Type::File::HtmlFormat
  include Card::Set::Abstract::Import::HtmlFormat

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
