include_set Type::File
include_set Abstract::ImportWithMapping

attachment :answer_import_file, uploader: CarrierWave::FileCardUploader

def csv_columns
  {
    metric: { map: true, require: true },
    wikirate_company: { map: true, require: true },
    year: { map: true, require: true},
    value: { require: true },
    source: { map: true, require: true},
    comment: {}
  }
end

def csv_row_class
  CsvRow::Structure::AnswerCsv
end

def import_map_source_val val
  result = Self::Source.search val
  result.first.name if result.size == 1
end
