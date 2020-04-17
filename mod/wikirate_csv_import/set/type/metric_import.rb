include_set Abstract::WikirateImport

# following shouldn't be necessary.  handle in Abstract::Import
attachment :metric_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  MetricImportItem
end
