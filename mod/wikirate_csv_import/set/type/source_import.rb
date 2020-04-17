include_set Abstract::WikirateImport
include_set Type::File

attachment :source_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  SourceImportItem
end
