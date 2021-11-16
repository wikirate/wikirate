include_set Type::File
include_set Abstract::WikirateImport

attachment :file, uploader: CarrierWave::FileCardUploader

def import_item_class
  SourceImportItem
end
