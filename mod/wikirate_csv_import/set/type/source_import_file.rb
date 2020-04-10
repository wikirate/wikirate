include_set Abstract::WikirateImport

attachment :source_import_file, uploader: CarrierWave::FileCardUploader

COLUMNS = { checkbox: "Select",
            row_index: "#",
            company_correction: "Corrected Company",
            company: "<small>in file</small>",
            wikirate_company: "<small>on WikiRate</small>",
            year: "Year",
            report_type: "Report Type",
            source: "Source",
            comment: "Title" }.freeze

SUCCESS_MESSAGES = {
  updated_sources: "Existing sources updated",
  duplicated_sources: "Duplicated sources in import file. Only the first one is used."
}.freeze

def import_item_class
  ImportItem::Structure::SourceCsv
end

def item_label
  "source"
end

format :html do
  view :import do
    voo.hide :metric_select, :year_select
    super()
  end

  def import_table_row_class
    TableRowSource
  end
end
