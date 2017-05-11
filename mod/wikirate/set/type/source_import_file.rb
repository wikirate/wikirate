include_set Type::File
include_set Abstract::Import

attachment :source_import_file, uploader: CarrierWave::FileCardUploader

def success_params
  [:updated_sources, :duplicated_sources]
end

# @return updated or created metric value card object
def parse_import_row source, source_map
  args = process_data source
  return if check_duplication_within_file args, source_map
  return unless valid_value_data? args
  return unless ensure_company_exists args[:company], args
  process_source args, source_map
end

def process_source source_hash, source_map
  url = source_hash[:source]
  duplicates = Self::Source.find_duplicates url
  source_card =
    if duplicates.any?
      handle_duplicated_source duplicates.first.left, source_hash
      nil
    else
      create_source source_hash
    end
  source_map[url] = source_card
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

def create_or_update_pointer_subcard source_card, trait, content
  trait = hashkey_to_codename trait
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

def hashkey_to_codename hashkey
  case hashkey
  when :company
    :wikirate_company
  else
    hashkey
  end
end

def update_existing_source source_card, source_hash
  [:report_type, :company, :year].inject(false) do |updated, e|
    create_or_update_pointer_subcard(source_card, e, source_hash[e]) || updated
  end
end

def update_title_card source_card, source_hash
  title = Env.params[:title][source_hash[:row].to_s]
  title_card = source_card.fetch trait: :wikirate_title,
                                 new: { content: title }
  return unless title_card.new?
  add_subcard title_card
end

def handle_duplicated_source source_card, source_hash
  # title is missing, then add the title
  #   add company and report type to the related fields
  #   add to warning message
  updated = false
  updated |= update_title_card source_card, source_hash
  updated |= update_existing_source source_card, source_hash
  return unless updated
  msg_array = [source_hash[:row].to_s, source_card.name]
  success[:updated_sources].push(msg_array)
end

def check_duplication_within_file source_hash, source_map
  source_url = source_hash[:source]
  if source_map[source_url]
    msg = [source_hash[:row].to_s, source_url]
    success.params[:duplicated_sources].push(msg)
    return true
  end
  false
end

def valid_value_data? args
  collect_import_errors(args[:row]) do
    %w[company year report_type source].each do |field|
      check_if_filled_in field, args
    end
  end
end

format :html do
  include Type::MetricValueImportFile::HtmlFormat
  def default_import_table_args args
    args[:table_header] = ["Select", "#",  "Company in File",
                           "Company in Wikirate",
                           "Corrected Company",
                           "Year", "Report Type", "Source", "Title"]
    args[:table_fields] = [:checkbox, :row, :file_company,
                           :wikirate_company, :correction,
                           :year, :report_type, :source, :title]
  end

  def duplicated_value_warning_message headline, cardnames
    message = cardnames.map do |err_row|
      "Row #{err_row[0]}: #{err_row[1]}"
    end.join("</li><li>")
    alert("warning") do
      <<-HTML
        <h4><b>#{headline}</b></h4>
        <ul><li>#{message}</li> <br />
      HTML
    end
  end

  def construct_import_warning_message
    msg = ""
    if (updated_sources = Env.params[:updated_sources])
      headline = "Existing sources updated"
      msg += duplicated_value_warning_message headline, updated_sources
    end
    if (duplicated_sources = Env.params[:duplicated_sources])
      headline = "Duplicated sources in import file."\
                 " Only the first one is used."
      msg += duplicated_value_warning_message headline, duplicated_sources
    end
    msg
  end

  view :import do
    voo.hide :metric_select, :year_select
    super()
  end

  view :import_flag do
    hidden_field_tag :is_data_import, "true"
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
    text_field_tag("title[#{row_hash[:row]}]", default_title,
                   class: "min-width-300")
  end

  def finalize_row row, index
    row[:row] = index
    row[:checkbox] = import_checkbox row
    row[:correction] = data_correction row
    row[:title] = title_field row
    row
  end
  # def prepare_import_row_data row, index
  #   data = super row, index
  #   data[:title] = title_field data
  #   data
  # end
end
