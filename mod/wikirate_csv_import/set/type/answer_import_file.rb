include_set Type::File
include_set Abstract::ImportWithMapping

attachment :answer_import_file, uploader: CarrierWave::FileCardUploader

def csv_row_class
  CsvRow::Structure::AnswerCsv
end

def import_map_source_val val
  result = Self::Source.search val
  result.first.id if result.size == 1
end
