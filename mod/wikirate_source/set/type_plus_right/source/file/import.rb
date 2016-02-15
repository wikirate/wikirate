
event :validate_import, :prepare_to_validate,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
  metric_pointer_card = subcard(cardname.left + "+#{Card[:metric].name}")
  metric_year = subcard(cardname.left + "+#{Card[:year].name}")

  if !metric_pointer_card ||
     !(metric_card = metric_pointer_card.item_cards.first)
    errors.add :content, 'Please give a metric.'
  elsif metric_card.type_id != Card::MetricID
    errors.add :content, 'Invalid metric'
  end

  if !metric_year || !(year_card = metric_year.item_cards.first)
    errors.add :content, 'Please give a year.'
  elsif year_card.type_id != Card::YearID
    errors.add :content, 'Invalid Year'
  end
end

event :import_csv, :prepare_to_store,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
  metric_pointer_card = subcards[cardname.left + "+#{Card[:metric].name}"]
  metric_year = subcards[cardname.left + "+#{Card[:year].name}"]

  corrected_company_hash = Hash.new
  if (corrected_company_name = Env.params[:corrected_company_name]) &&
     corrected_company_name.is_a?(Hash)
    corrected_company_hash = corrected_company_name
    corrected_company_hash.delete_if { |_k, v| v.nil? || v.empty? }
  end
  if (metric_values = Env.params[:metric_values]) && metric_values.is_a?(Hash)
    metric_values.each do |company, value|
      final_company_name = company
      if (input_company_name = (corrected_company_hash[company] || company))
        final_company_name = input_company_name
        if !Card.exists? input_company_name
          Card.create! name: input_company_name, type_id: WikirateCompanyID
        end
      end
      metric_value_card_name =
        [metric_pointer_card.item_names.first,
         final_company_name,
         metric_year.item_names.first].join '+'

      _subcard = {
        '+metric' => { 'content' => metric_pointer_card.content },
        '+company' => { 'content' => "[[#{final_company_name}]]",
                        :type_id => PointerID },
        '+value' => { 'content' => value[0], :type_id => PhraseID },
        '+year' => { 'content' => metric_year.content, :type_id => PointerID },
        '+source' => {
          'subcards' => {
            'new source' => {
              '+Link' => {
                'content' => "#{Env[:protocol]}#{Env[:host]}" \
                             "/#{left.cardname.url_key}",
                'type_id' => PhraseID
              }
            }
          }
        }
      }
      metric_value_card =
        if (metric_value_card = Card[metric_value_card_name])
          metric_value_card.update_attributes subcards: _subcard
          metric_value_card
        else
          Card.create type_id: Card::MetricValueID, subcards: _subcard
        end
      if !metric_value_card.errors.empty?
        metric_value_card.errors.each do |key, _value|
          errors.add key, _value
        end
      end
    end
    if errors.empty?
      abort success: {
        name: metric_pointer_card.item_names.first,
        redirect: true,
        view: :open
      }
    else
      abort :failure
    end
  end
end

def csv_rows
  # transcode to utf8 before CSV reads it.
  # some users upload files in non utf8 encoding.
  # The microsoft excel may not save a CSV file in utf8 encoding
  CSV.read(file.path, encoding: 'windows-1251:utf-8')
end

def clean_html? # return always true ;)
  false
end

format :html do
  def get_aliases_hash
    aliases_hash = Hash.new
    aliases_cards = Card.search right: 'aliases',
                                left: { type_id: WikirateCompanyID }
    aliases_cards.each do |aliases_card|
      aliases_card.item_names.each do |name|
        aliases_hash[name.downcase] = aliases_card.cardname.left
      end
    end
    aliases_hash
  end

  def render_row hash, row
    file_company, value = row
    wikirate_company, status = matched_company(hash, file_company)
    row_content = checkbox_row file_company, wikirate_company, status, value
    if status != :exact
      comp_name = wikirate_company.empty? ? file_company : wikirate_company
      row_content += field_to_correct_company comp_name
    end
    row_content
  end

  def checkbox_row file_company, wikirate_company, status, value
    checked = [:partial, :exact, :alias].include? status
    checkbox =
      content_tag(:td) do
        check_box_tag "metric_values[#{wikirate_company}][]", value, checked
      end

    [file_company, wikirate_company, status.to_s].inject(checkbox) do |row, itm|
      row.concat content_tag(:td, itm)
    end
  end

  def field_to_correct_company comp_name
    input = text_field_tag("corrected_company_name[#{comp_name}]", '',
                           class: 'company_autocomplete')
    content_tag(:td, input)
  end

  def matched_company aliases_hash, name
    if (company = Card.fetch(name)) && company.type_id == WikirateCompanyID
      [name, :exact]
    # elsif (result = Card.search :right=>"aliases",
    # :left=>{:type_id=>Card::WikirateCompanyID},
    # :content=>["match","\\[\\[#{name}\\]\\]"]) && !result.empty?
    #   [result.first.cardname.left, :alias]
    elsif (company_name = aliases_hash[name.downcase])
      [company_name, :alias]
    elsif (result = Card.search type: 'company', name: ['match', name]) &&
          !result.empty?
      [result.first.name, :partial]
    elsif (company_name = part_of_a_company)
      [company_name, :partial]
    else
      ['', :none]
    end
  end

  def part_of_a_company
    Card.search(type: 'company', return: 'name').each do |comp|
      return comp if name.match comp
    end
  end

  def default_import_args args
    args[:buttons] = %{
      #{button_tag 'Import', class: 'submit-button',
                             data: { disable_with: 'Importing' }}
      #{button_tag 'Cancel', class: 'cancel-button slotter', href: path,
                             type: 'button'}
    }
  end

  view :import do |args|
    frame_and_form :update, args do
      [
        _optional_render(:metric_select, args),
        _optional_render(:year_select, args),
        _optional_render(:metric_import_flag, args),
        _optional_render(:selection_checkbox, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :year_select do |_args|
    nest card.left.year_card, view: :edit_in_form
  end

  view :metric_select do |_args|
    nest card.left.metric_card, view: :edit_in_form
  end

  view :metric_import_flag do |_args|
    hidden_field_tag :is_metric_import_update, 'true'
  end

  view :selection_checkbox do |_args|
    content = %{
      #{check_box_tag 'uncheck_all', '', false, class: 'checkbox-button'}
      #{label_tag 'Uncheck All'}
      #{check_box_tag 'partial', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Partial'}
      #{check_box_tag 'exact', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Exact'}
    }
    content_tag(:div, content, { class: 'selection_checkboxs' }, false)
  end

  view :import_table do |_args|
    header = ['Select', 'Company in File', 'Company in Wikirate', 'Match',
              'Correction']
    thead = content_tag :thead do
      content_tag :tr do
        header.map { |title|  content_tag(:th, title) }.join.html_safe
      end.html_safe
    end.html_safe
    aliases_hash = get_aliases_hash
    tbody = content_tag :tbody do
      wrap_each_with :tr  do
        card.csv_rows.map { |elem| render_row(aliases_hash, elem) }
      end.html_safe
    end.html_safe
    content_tag(
      :table, thead.concat(tbody),
      class: 'import_table table table-bordered table-hover'
    ).html_safe
  end
end
