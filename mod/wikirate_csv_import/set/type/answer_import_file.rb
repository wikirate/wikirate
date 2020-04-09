include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :answer_import_file, uploader: CarrierWave::FileCardUploader

def import_item_class
  AnswerImportItem
end

def import_map_source_val val
  result = Self::Source.search val
  result.first.id if result.size == 1
end
