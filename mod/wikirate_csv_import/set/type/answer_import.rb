include_set Abstract::WikirateImport
include_set Type::File

# following shouldn't be necessary.  handle in Abstract::Import
attachment :answer_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  AnswerImportItem
end
