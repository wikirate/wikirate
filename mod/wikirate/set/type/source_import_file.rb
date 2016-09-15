include_set Type::File
include_set Abstract::Import

attachment :source_import_file, uploader: CarrierWave::FileCardUploader

event :import_csv, :prepare_to_store,
      on: :update,
      when: proc { Env.params["is_source_import_update"] == "true" } do
  return unless (sources = Env.params[:sources])
  return unless valid_import_format?(sources)
  source_map = {}
  success.params[:slot] = {
    updated_sources: [],
    duplicated_sources: []
  }
  sources.each do |source|
    source_card = parse_source_card source, source_map
    if source_card
      source_card.director.catch_up_to_stage :validate
      source_card.director.transact_in_stage = :integrate
    end
    handle_import_errors source_card
  end
  clear_slot_params
  handle_redirect
end

def source_args source_hash
  args = super source_hash[:source]
  args.merge(
    "+title" => { content: Env.params[:title][source_hash[:row].to_s] },
    "+report_type" => { content: "[[#{source_hash[:report_type]}]]" },
    "+company" => { content: "[[#{source_hash[:company]}]]" },
    "+year" => { content: "[[#{source_hash[:year]}]]" }
  )
end

def create_source source_hash
  source_card = add_subcard "", type_id: SourceID,
                                subcards: source_args(source_hash)
  Env.params[:sourcebox] = "true"
  source_card.director.catch_up_to_stage :prepare_to_store
  Env.params[:sourcebox] = nil
  unless source_card.errors.empty?
    source_card.errors.each { |k, v| errors.add k, v }
  end
  source_card
end

def create_or_update_subcard source_card, trait, content
  trait_card = source_card.fetch trait: trait,
                                 new: { content: "[[#{content}]]" }
  if trait_card.new?
    add_subcard trait_card
  elsif !trait_card.item_names.include?(content)
    trait_card.add_item content
    add_subcard trait_card
  else
    return false
  end
  true
end

def update_existing_source source_card, source_hash
  report_type = source_hash[:report_type]
  updated = create_or_update_subcard source_card, :report_type, report_type

  company = source_hash[:company]
  updated |= create_or_update_subcard source_card, :wikirate_company, company

  year = source_hash[:year]
  updated |= create_or_update_subcard source_card, :year, year
  updated
end

def update_title_card source_card, source_hash
  title = Env.params[:title][source_hash[:row].to_s]
  title_card = source_card.fetch trait: :wikirate_title,
                                 new: { content: title }
  if title_card.new?
    add_subcard title_card
    return true
  end
  false
end

def handle_duplicated_source source_card, source_hash
  # title is missing, then add the title
  #   add company and report type to the related fields
  #   add to warning message
  updated = false
  updated |= update_title_card source_card, source_hash
  updated |= update_existing_source source_card, source_hash
  if updated
    slot_args = success.slot
    msg_array = [source_hash[:row].to_s, source_card.name]
    slot_args[:updated_sources].push(msg_array)
  end
  nil
end

def process_source source_hash, source_map
  url = source_hash[:source]
  duplicates = Self::Source.find_duplicates url
  source_card =
    if duplicates.any?
      handle_duplicated_source duplicates.first.left, source_hash
    else
      create_source source_hash
    end
  source_map[url] = source_card
end

def check_duplication_within_file source_hash, source_map
  slot_args = success.slot
  source_url = source_hash[:source]
  if source_map[source_url]
    msg = [source_hash[:row].to_s, source_url]
    slot_args[:duplicated_sources].push(msg)
    return true
  end
  false
end

def valid_value_data? args
  @import_errors = []
  %w(wikirate_company year report_type source).each do |field|
    add_import_error "#{field} missing", args[:row] if args[field.to_sym].blank?
  end
  @import_errors.empty?
end

# @return updated or created metric value card object
def parse_source_card source, source_map
  # check if duplicate in file
  # if yes, add warning message and next
  # check if source exists in db
  # if yes,
  #   title is missing, then add the title
  #   add company and report type to the related fields
  #   add to warning message
  #   add to subcard
  # no,
  #   contruct the create args and add to subcards
  args = process_data source
  return if check_duplication_within_file args, source_map
  return unless valid_value_data? args
  return unless ensure_company_exists args[:company], args
  process_source args, source_map
end

format :html do
  include Type::MetricValueImportFile::HtmlFormat
  def default_import_table_args args
    args[:table_header] = ["Select", "#",  "Company in File",
                           "Company in Wikirate", "Match",
                           "Correction",
                           "Year", "Report Type", "Source", "Title"]
    args[:table_fields] = [:checkbox, :row, :file_company,
                           :wikirate_company, :status, :correction,
                           :year, :report_type, :source, :title]
  end

  def duplicated_value_warning_message headline, cardnames
    message = cardnames.map do |err_row|
      "Row #{err_row[0]}: #{err_row[1]}"
    end.join("</li><li>")
    msg = <<-HTML
      <h4><b>#{headline}</b></h4>
      <ul><li>#{message}</li> <br />
    HTML
    alert("warning") { msg }
  end

  def contruct_import_warning_message args
    msg = ""
    if (updated_sources = args[:updated_sources])
      headline = "Existing sources updated"
      msg += duplicated_value_warning_message headline, updated_sources
    end
    if (duplicated_sources = args[:duplicated_sources])
      headline = "Duplicated sources in import file."\
                 " Only the first one is used."
      msg += duplicated_value_warning_message headline, duplicated_sources
    end
    msg
  end

  view :import do |args|
    new_args = args.merge(hidden: { success: { id: "_self", view: :open } })
    frame_and_form :update, new_args, "notify-success" => "import successful" do
      [
        _optional_render(:source_import_flag, args),
        _optional_render(:selection_checkbox, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :source_import_flag do |_args|
    hidden_field_tag :is_source_import_update, "true"
  end

  def import_fields
    [:file_company, :year, :report_type, :source, :title]
  end

  def title_field row_hash
    default_title = row_hash[:title]
    if default_title.nil? && row_hash[:status] == "exact"
      default_title =
        "#{row_hash[:company]}-#{row_hash[:report_type]}-#{row_hash[:year]}"
    end
    text_field_tag("title[#{row_hash[:row]}]", default_title)
  end

  def prepare_import_row_data row, index
    data = super row, index
    data[:title] = title_field data
    data
  end

  def import_checkbox row_hash
    key_hash, checked = prepare_import_checkbox row_hash
    check_box_tag "sources[]", key_hash.to_json, checked
  end
end
