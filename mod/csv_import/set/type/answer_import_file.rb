include_set Type::File
include_set Abstract::ImportWithCompanies

attachment :answer_import_file, uploader: CarrierWave::FileCardUploader

COLUMNS = { checkbox: "Select",
            row_index: "#",
            metric: "Metric",
            company_correction: "Company",
            company: "<small>in file</small>",
            wikirate_company: "<small>on WikiRate</small>",
            year: "Year",
            value: "Value",
            source: "Source",
            comment: "Comment" }.freeze

SUCCESS_MESSAGES =
  {
    identical_answer: "Metric answer exist and was not modified.",
    duplicated_answer: "Metric answer exist with different source and was not modified."
  }

def csv_row_class
  AnswerCSVRow
end

def item_label
  "metric answer"
end

format :html do
  def default_import_args _args
    voo.hide :metric_select, :year_select
  end

  def import_table_row_class
    TableRowWithCompanyMapping
  end
end
