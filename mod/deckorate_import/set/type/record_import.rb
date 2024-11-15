include_set Type::File
include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :record_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  RecordImportItem
end
