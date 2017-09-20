include_set Type::File
include_set Abstract::Import

attachment :source_import_file, uploader: CarrierWave::FileCardUploader


SUCCESS_MESSAGES = {
  updated_sources: "Existing sources updated",
  duplicated_sources: "Duplicated sources in import file. Only the first one is used."
}.freeze

COLUMNS = { checkbox: "Select",
            row_index: "#",
            company: "Company in File",
            wikirate_company: "Company in Wikirate",
            company_correciton: "Corrected Company",
            year: "Year",
            report_type: "Report Type",
            source: "Source",
            comment: "Title" }.freeze

format :html do
  view :import do
    voo.hide :metric_select, :year_select
    super()
  end

  def csv_row_class
    SourceCSVRow
  end

  def import_table_row_class
    TableRowSource
  end
end
