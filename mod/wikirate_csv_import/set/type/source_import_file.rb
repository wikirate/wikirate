include_set Abstract::WikirateImport

attachment :source_import_file, uploader: CarrierWave::FileCardUploader

def import_item_class
  SourceImportItem
end
