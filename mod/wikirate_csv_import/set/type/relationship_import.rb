include_set Abstract::WikirateImport
include_set Type::File

attachment :relationship_import, uploader: CarrierWave::FileCardUploader

def import_item_class
  RelationshipImportItem
end
