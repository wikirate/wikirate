include_set Type::File
include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :file, uploader: CarrierWave::FileCardUploader

def import_item_class
  AnswerImportItem
end
