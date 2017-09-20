include_set Type::File
include_set Abstract::Import

attachment :metric_value_import_file, uploader: CarrierWave::FileCardUploader

COLUMNS = { checkbox: "Select",
            row_index: "#",
            metric: "Metric",
            company: "Company in File",
            wikirate_company: "Company in Wikirate",
            company_correction: "Corrected Company",
            year: "Year",
            value: "Value",
            source: "Source",
            comment: "Comment" }.freeze

SUCCESS_MESSAGES =
  {
    identical_answer: "Metric answer exist and was not modified.",
    duplicated_answer: "Metric answer exist with different source and was not modified."
  }

format :html do
  def default_import_args _args
    voo.hide :metric_select, :year_select
  end

  def csv_row_class
    AnswerCSVRow
  end

  def import_table_row_class
    TableRowWithCompanyMapping
  end
end
