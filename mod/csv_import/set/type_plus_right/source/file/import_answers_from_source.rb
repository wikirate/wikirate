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
  check_card metric, "Metric", Card::MetricID
  check_card year, "Year", Card::YearID
end

def csv_only?
  false
end

def csv_row_class
  CSVRow::Structure::AnswerFromSourceCSV
end

def metric
  extra_data.dig(:all, :corrections, :metric)
end

def year
  extra_data.dig(:all, :corrections, :year)
end

def normalize_extra_data
  data = super
  %i[metric year].each do |key|
    next unless (value = data.dig(:all, :corrections, key, :content))
    data[:all][:corrections][key] = value.tr("[", "").tr("]", "")
  end
  add_source data
  data
end

def add_source data
  data.deep_merge! all: { corrections: { source: left.name } }
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
    nest card.left.year_card, { view: :edit_in_form },
         explicit_form_prefix: corrections_input_name(:all, :year)
  end

  def metric_select
    nest card.left.metric_card, { view: :edit_in_form },
         explicit_form_prefix: corrections_input_name(:all, :year)
  end

  def import_table_row_class
    Abstract::Import::TableRowWithCompanyMapping
  end

  def humanized_attachment_name
    "source file"
  end
end
