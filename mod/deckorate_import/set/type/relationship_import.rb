include_set Type::File
include_set Abstract::WikirateImport

attachment :relationship_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  RelationshipImportItem
end
