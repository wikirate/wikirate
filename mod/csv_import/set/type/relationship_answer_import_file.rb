include_set Type::File
include_set Abstract::ImportWithCompanies

attachment :relationship_answer_import_file, uploader: CarrierWave::FileCardUploader

COLUMNS = {
  checkbox: "Select",
  row_index: "Row",
  metric: "Metric",
  company_correction: "Company",
  company: "<small>in file</small>",
  wikirate_company: "<small>on WikiRate</small>",
  related_company_correction: "Related Company",
  related_company: "<small>in file</small>",
  related_wikirate_company: "<small>on WikiRate</small>",
  year: "Year",
  value: "Value",
  source: "Source",
  comment: "Comment"
}

def csv_row_class
  CSVRow::Structure::RelationshipAnswerCSV
end

def item_label
  "relationship answer"
end

format :html do
  def import_table_row_class
    Abstract::Import::TableRowRelationship
  end


  def construct_import_warning_message
    msg = ""
    if (identical_metric_values = Env.params[:identical_metric_value])
      headline = "Relationships exist and are not modified."
      msg += duplicated_value_warning_message headline, identical_metric_values
    end
    if (duplicated_metric_values = Env.params[:duplicated_metric_value])
      headline = "Relationships exist with different source and are not "\
                 "modified."
      msg += duplicated_value_warning_message headline, duplicated_metric_values
    end
    msg
  end
end
