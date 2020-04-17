include_set Abstract::WikirateImport

attachment :source_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  SourceImportItem
end
