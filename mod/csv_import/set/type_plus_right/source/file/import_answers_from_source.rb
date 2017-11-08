include_set Abstract::ImportWithCompanies

COLUMNS = { checkbox: "Select",
            row_index: "#",
            company_correction: "Company",
            company: "<small>in file</small>",
            wikirate_company: "<small>on WikiRate</small>",
            value: "Value" }.freeze

event :validate_import, :prepare_to_validate,
      on: :update,
      when: :data_import? do
  normalize_extra_data
  check_card metric, "Metric", Card::MetricID
  check_card year, "Year", Card::YearID
end

def csv_row_class
  CSVRow::Structure::AnswerFromSourceCSV
end

def metric
  extra_data.dig(:all, :corrections, :metric)&.tr("[","")&.tr("]","")
end

def year
  extra_data.dig(:all, :corrections, :year)&.tr("[","")&.tr("]","")
end

def normalize_extra_data
  %i[metric year].each do |key|
    next unless (value = extra_data.dig(:all, :corrections, key, :content))
    @extra_data[:all][:corrections][key] = value
  end
  add_source_to_extra_data
end

def add_source_to_extra_data
  @extra_data.deep_merge! all: { corrections: { source: left.name } }
end

def check_card card_name, type_name, type_id
  if !(card = Card[card_name])
    errors.add :content, "Please give a #{type_name}."
  elsif card.type_id != type_id
    errors.add :content, "Invalid #{name}"
  end
end

format :html do
  view :additional_form_fields, cache: :never do
    metric_select + year_select
  end

  def year_select
    nest card.left.year_card,
         view: :edit_in_form,
         input_name: corrections_input_name(:all, :year)
  end

  def metric_select
    nest card.left.metric_card,
         view: :edit_in_form,
         input_name: corrections_input_name(:all, :metric)
  end

  def import_table_row_class
    Abstract::Import::TableRowWithCompanyMapping
  end

  def humanized_attachment_name
    "source file"
  end
end
