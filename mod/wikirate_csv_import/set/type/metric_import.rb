include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :answer_import_file, uploader: CarrierWave::FileCardUploader

def import_item_class
  MetricImportItem
end
